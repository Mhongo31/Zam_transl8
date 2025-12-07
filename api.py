from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import torch
import logging
import os
from dotenv import load_dotenv
from supabase import create_client, Client
import time
from typing import Optional

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Zam Transl8 API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Supabase client
supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase: Optional[Client] = None

if supabase_url and supabase_key:
    try:
        supabase = create_client(supabase_url, supabase_key)
        logger.info("Supabase client initialized")
    except Exception as e:
        logger.error(f"Error initializing Supabase client: {e}")

# Global variables for model and tokenizer
model = None
tokenizer = None
device = "cpu"

# Simple in-memory cache for translations (max 100 entries)
translation_cache = {}
MAX_CACHE_SIZE = 100

class TranslationRequest(BaseModel):
    text: str
    direction: str  # "en_to_lu" or "lu_to_en"

class TranslationResponse(BaseModel):
    translation: str
    direction: str
    input_text: str

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    device: str

def load_model():
    """Load the fine-tuned model from checkpoint"""
    global model, tokenizer, device
    
    try:
        logger.info("Loading fine-tuned BART model from checkpoint...")
        
        # Load from local checkpoint
        checkpoint_path = "checkpoints/bart_fine_tuned/checkpoint-22500"
        
        # Load tokenizer
        tokenizer = AutoTokenizer.from_pretrained(checkpoint_path)
        
        # Load model with memory optimization
        model = AutoModelForSeq2SeqLM.from_pretrained(
            checkpoint_path,
            torch_dtype=torch.float16,  # Use half precision to save memory
            low_cpu_mem_usage=True
        )
        
        # Move to CPU and set to eval mode
        model.to(device)
        model.eval()
        
        logger.info("Fine-tuned BART model loaded successfully!")
        return True
        
    except Exception as e:
        logger.error(f"Error loading model: {e}")
        return False

@app.on_event("startup")
async def startup_event():
    """Load model on startup"""
    success = load_model()
    if not success:
        logger.error("Failed to load model on startup")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Zam Transl8 API",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "translate": "/translate (POST)",
            "history": "/history"
        }
    }

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy" if model is not None else "unhealthy",
        model_loaded=model is not None,
        device=device
    )

@app.post("/translate", response_model=TranslationResponse)
async def translate_text(request: TranslationRequest):
    """Translate text between English and Lunda"""
    if model is None or tokenizer is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    start_time = time.time()
    
    try:
        # Check cache first (fast lookup)
        cache_key = f"{request.direction}:{request.text.lower().strip()}"
        if cache_key in translation_cache:
            cached_result = translation_cache[cache_key]
            logger.info(f"Translation from cache: {request.direction} - '{request.text}' -> '{cached_result}'")
            return TranslationResponse(
                translation=cached_result,
                direction=request.direction,
                input_text=request.text
            )
        
        # Prepare input text with direction prefix
        if request.direction == "en_to_lu":
            input_text = f"<EN_TO_LU> {request.text}"
        else:
            input_text = f"<LU_TO_EN> {request.text}"
        
        # Tokenize input (optimized: no padding, dynamic length)
        inputs = tokenizer(
            input_text,
            max_length=64,  # Reduced from 128 for faster processing
            padding=False,  # No padding needed for single inputs
            truncation=True,
            return_tensors='pt'
        )
        
        # Move inputs to device
        inputs = {k: v.to(device) for k, v in inputs.items()}
        
        # Generate translation (optimized for speed)
        # Using inference_mode() is faster than no_grad() for inference
        with torch.inference_mode():
            outputs = model.generate(
                input_ids=inputs['input_ids'],
                attention_mask=inputs['attention_mask'],
                max_length=64,  # Reduced from 128
                num_beams=1,  # Greedy decoding (faster than beam search)
                early_stopping=False,  # Not needed for greedy decoding
                pad_token_id=tokenizer.pad_token_id,
                eos_token_id=tokenizer.eos_token_id,
                do_sample=False,  # Deterministic, faster
                num_return_sequences=1
            )
        
        # Decode output
        output_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        # Cache the result (with size limit)
        if len(translation_cache) >= MAX_CACHE_SIZE:
            # Remove oldest entry (simple FIFO)
            oldest_key = next(iter(translation_cache))
            del translation_cache[oldest_key]
        translation_cache[cache_key] = output_text
        
        # Log to Supabase if available
        if supabase:
            try:
                supabase.table("translations").insert({
                    "direction": request.direction,
                    "source_text": request.text,
                    "translated_text": output_text,
                    "latency_ms": int((time.time() - start_time) * 1000),
                    "model_checkpoint": "checkpoint-22500"
                }).execute()
                logger.info("Translation logged to Supabase")
            except Exception as e:
                logger.error(f"Failed to log translation to Supabase: {e}")
        
        logger.info(f"Translation completed: {request.direction} - '{request.text}' -> '{output_text}'")
        
        return TranslationResponse(
            translation=output_text,
            direction=request.direction,
            input_text=request.text
        )
        
    except Exception as e:
        logger.error(f"Translation error: {e}")
        raise HTTPException(status_code=500, detail=f"Translation failed: {str(e)}")

@app.get("/history")
async def get_translation_history(limit: int = 50, offset: int = 0):
    """Get translation history from Supabase"""
    if supabase is None:
        raise HTTPException(status_code=503, detail="Database not connected")
    
    try:
        result = supabase.table("translations").select("*").order("created_at", desc=True).range(offset, offset + limit - 1).execute()
        return {
            "translations": result.data,
            "count": len(result.data),
            "limit": limit,
            "offset": offset
        }
    except Exception as e:
        logger.error(f"Failed to fetch translation history: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch translation history")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)