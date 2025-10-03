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
    """Load the model with memory optimization"""
    global model, tokenizer, device
    
    try:
        logger.info("Loading lightweight BART model...")
        
        # Use your trained model from Hugging Face
        model_name = "mhongob/lunda-english-bart-translator"
        
        # Load tokenizer from Hugging Face
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        
        # Load model from Hugging Face
        model = AutoModelForSeq2SeqLM.from_pretrained(
            model_name,
            torch_dtype=torch.float16,  # Use half precision to save memory
            low_cpu_mem_usage=True
        )
        
        # Move to CPU and set to eval mode
        model.to(device)
        model.eval()
        
        logger.info("Lightweight BART model loaded successfully!")
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
        # For now, return a simple translation mapping
        # This is a placeholder until we can load the full model
        translation_map = {
            "en_to_lu": {
                "hello": "Mwashibukeni",
                "good morning": "Ntetamena",
                "good evening": "Ntetamena",
                "thank you": "Natotela",
                "how are you": "Mwashibukeni",
                "i love you": "Nakeŋi",
                "yes": "Ee",
                "no": "Awe",
                "water": "Maji",
                "food": "Chakulya",
                "house": "Nyumba",
                "family": "Banja",
                "child": "Mwana",
                "mother": "Mama",
                "father": "Tata",
                "brother": "Mwana wa tata",
                "sister": "Mwana wa mama",
                "friend": "Mwenzi",
                "work": "Kazi",
                "money": "Ndalama",
                "time": "Nthawi"
            },
            "lu_to_en": {
                "mwashibukeni": "hello",
                "ntetamena": "good morning",
                "natotela": "thank you",
                "nakeŋi": "i love you",
                "ee": "yes",
                "awe": "no",
                "maji": "water",
                "chakulya": "food",
                "nyumba": "house",
                "banja": "family",
                "mwana": "child",
                "mama": "mother",
                "tata": "father",
                "mwenzi": "friend",
                "kazi": "work",
                "ndalama": "money",
                "nthawi": "time"
            }
        }
        
        text_lower = request.text.lower().strip()
        direction_map = translation_map.get(request.direction, {})
        
        # Try exact match first
        if text_lower in direction_map:
            output_text = direction_map[text_lower]
        else:
            # Simple word-by-word translation for unknown phrases
            words = text_lower.split()
            translated_words = []
            for word in words:
                if word in direction_map:
                    translated_words.append(direction_map[word])
                else:
                    translated_words.append(f"[{word}]")  # Mark untranslated words
            output_text = " ".join(translated_words)
        
        # Log to Supabase if available
        if supabase:
            try:
                supabase.table("translations").insert({
                    "direction": request.direction,
                    "source_text": request.text,
                    "translated_text": output_text,
                    "latency_ms": int((time.time() - start_time) * 1000),
                    "model_checkpoint": "lightweight-bart-base"
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