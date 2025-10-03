"""
Fine-tune BART model on Lunda-English translation data.
"""

import os
import pandas as pd
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
from transformers import (
    BartForConditionalGeneration, 
    BartTokenizer, 
    AdamW, 
    get_linear_schedule_with_warmup,
    TrainingArguments,
    Trainer
)
from sklearn.model_selection import train_test_split
import numpy as np
from tqdm import tqdm
import json

class LundaEnglishDataset(Dataset):
    """Dataset for Lunda-English translation pairs."""
    
    def __init__(self, texts, targets, tokenizer, max_length=128):
        self.texts = texts
        self.targets = targets
        self.tokenizer = tokenizer
        self.max_length = max_length
    
    def __len__(self):
        return len(self.texts)
    
    def __getitem__(self, idx):
        text = str(self.texts[idx])
        target = str(self.targets[idx])
        
        # Add direction prefix to input
        if "en_to_lu" in text or "lu_to_en" in text:
            # Already has direction prefix
            input_text = text
        else:
            # Determine direction from context (you may need to adjust this)
            input_text = f"<EN_TO_LU> {text}"
        
        # Tokenize inputs
        inputs = self.tokenizer(
            input_text,
            max_length=self.max_length,
            padding='max_length',
            truncation=True,
            return_tensors='pt'
        )
        
        # Tokenize targets
        with self.tokenizer.as_target_tokenizer():
            labels = self.tokenizer(
                target,
                max_length=self.max_length,
                padding='max_length',
                truncation=True,
                return_tensors='pt'
            )
        
        return {
            'input_ids': inputs['input_ids'].flatten(),
            'attention_mask': inputs['attention_mask'].flatten(),
            'labels': labels['input_ids'].flatten()
        }

def load_and_prepare_data(csv_path, test_size=0.1):
    """Load and prepare the CSV data for training."""
    print("📊 Loading CSV data...")
    
    # Load CSV
    df = pd.read_csv(csv_path)
    print(f"✅ Loaded {len(df)} rows from CSV")
    
    # Check columns
    print(f"📋 Columns: {list(df.columns)}")
    
    # Look for translation pairs
    if 'example_direction' in df.columns:
        print("🎯 Found 'example_direction' column")
        
        # Filter by direction
        en_to_lu_data = df[df['example_direction'] == 'en_to_lu']
        lu_to_en_data = df[df['example_direction'] == 'lu_to_en']
        
        print(f"📈 English → Lunda: {len(en_to_lu_data)} pairs")
        print(f"📈 Lunda → English: {len(lu_to_en_data)} pairs")
        
        # Prepare training data
        texts = []
        targets = []
        
        # Add English to Lunda pairs
        for _, row in en_to_lu_data.iterrows():
            if 'english' in df.columns and 'lunda' in df.columns:
                texts.append(f"<EN_TO_LU> {row['english']}")
                targets.append(row['lunda'])
            elif 'source' in df.columns and 'target' in df.columns:
                texts.append(f"<EN_TO_LU> {row['source']}")
                targets.append(row['target'])
        
        # Add Lunda to English pairs
        for _, row in lu_to_en_data.iterrows():
            if 'english' in df.columns and 'lunda' in df.columns:
                texts.append(f"<LU_TO_EN> {row['lunda']}")
                targets.append(row['english'])
            elif 'source' in df.columns and 'target' in df.columns:
                texts.append(f"<LU_TO_EN> {row['source']}")
                targets.append(row['target'])
        
    else:
        print("⚠️  No 'example_direction' column found, trying to infer...")
        
        # Try to infer from column names
        if 'English' in df.columns and 'Lunda' in df.columns:
            print("🔍 Found 'English' and 'Lunda' columns")
            
            # Create bidirectional pairs
            texts = []
            targets = []
            
            for _, row in df.iterrows():
                if pd.notna(row['English']) and pd.notna(row['Lunda']):
                    # English to Lunda
                    texts.append(f"<EN_TO_LU> {row['English']}")
                    targets.append(row['Lunda'])
                    
                    # Lunda to English
                    texts.append(f"<LU_TO_EN> {row['Lunda']}")
                    targets.append(row['English'])
        
        elif 'english' in df.columns and 'lunda' in df.columns:
            print("🔍 Found 'english' and 'lunda' columns")
            
            # Create bidirectional pairs
            texts = []
            targets = []
            
            for _, row in df.iterrows():
                if pd.notna(row['english']) and pd.notna(row['lunda']):
                    # English to Lunda
                    texts.append(f"<EN_TO_LU> {row['english']}")
                    targets.append(row['lunda'])
                    
                    # Lunda to English
                    texts.append(f"<LU_TO_EN> {row['lunda']}")
                    targets.append(row['english'])
        
        elif 'source' in df.columns and 'target' in df.columns:
            print("🔍 Found 'source' and 'target' columns")
            
            # Assume source is English, target is Lunda
            texts = []
            targets = []
            
            for _, row in df.iterrows():
                if pd.notna(row['source']) and pd.notna(row['target']):
                    # Source to Target
                    texts.append(f"<EN_TO_LU> {row['source']}")
                    targets.append(row['target'])
                    
                    # Target to Source
                    texts.append(f"<LU_TO_EN> {row['target']}")
                    targets.append(row['source'])
        
        else:
            print("❌ Could not identify translation columns")
            print("Available columns:", list(df.columns))
            return None, None, None, None
    
    print(f"✅ Prepared {len(texts)} training pairs")
    
    # Split into train/validation
    train_texts, val_texts, train_targets, val_targets = train_test_split(
        texts, targets, test_size=test_size, random_state=42
    )
    
    print(f"📚 Training set: {len(train_texts)} pairs")
    print(f"🧪 Validation set: {len(val_targets)} pairs")
    
    return train_texts, val_texts, train_targets, val_targets

def fine_tune_bart(
    model_name='facebook/bart-base',
    csv_path='data/lunda_data_grammar_enhanced.csv',
    output_dir='checkpoints/bart_fine_tuned',
    num_epochs=10,
    batch_size=8,
    learning_rate=5e-5,
    max_length=128
):
    """Fine-tune BART model on Lunda-English data."""
    
    print("=" * 70)
    print("🚀 BART FINE-TUNING ON LUNDA-ENGLISH DATA")
    print("=" * 70)
    
    # Check if CUDA is available
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"🖥️  Using device: {device}")
    
    # 1. Load and prepare data
    train_texts, val_texts, train_targets, val_targets = load_and_prepare_data(csv_path)
    
    if train_texts is None:
        print("❌ Failed to prepare data")
        return None
    
    # 2. Load BART model and tokenizer
    print("\n🔧 Loading BART model and tokenizer...")
    try:
        tokenizer = BartTokenizer.from_pretrained(model_name)
        model = BartForConditionalGeneration.from_pretrained(model_name)
        
        # Add special tokens for direction
        special_tokens = {
            'additional_special_tokens': ['<EN_TO_LU>', '<LU_TO_EN>']
        }
        tokenizer.add_special_tokens(special_tokens)
        
        # Resize token embeddings
        model.resize_token_embeddings(len(tokenizer))
        
        print("✅ BART model and tokenizer loaded successfully!")
        print(f"📊 Vocabulary size: {len(tokenizer)}")
        
    except Exception as e:
        print(f"❌ Error loading BART: {e}")
        return None
    
    # 3. Create datasets
    print("\n📚 Creating datasets...")
    train_dataset = LundaEnglishDataset(train_texts, train_targets, tokenizer, max_length)
    val_dataset = LundaEnglishDataset(val_texts, val_targets, tokenizer, max_length)
    
    # 4. Set up training arguments
    print("\n⚙️  Setting up training...")
    training_args = TrainingArguments(
        output_dir=output_dir,
        num_train_epochs=num_epochs,
        per_device_train_batch_size=batch_size,
        per_device_eval_batch_size=batch_size,
        warmup_steps=100,
        weight_decay=0.01,
        logging_dir=f"{output_dir}/logs",
        logging_steps=10,
        evaluation_strategy="steps",
        eval_steps=100,
        save_steps=500,
        save_total_limit=2,
        load_best_model_at_end=True,
        metric_for_best_model="eval_loss",
        greater_is_better=False,
        report_to=None,  # Disable wandb
        dataloader_pin_memory=False,
    )
    
    # 5. Initialize trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=val_dataset,
        tokenizer=tokenizer,
    )
    
    # 6. Start training
    print(f"\n🎯 Starting fine-tuning for {num_epochs} epochs...")
    print(f"📁 Output directory: {output_dir}")
    
    try:
        trainer.train()
        print("✅ Training completed successfully!")
        
        # 7. Save the fine-tuned model
        print("\n💾 Saving fine-tuned model...")
        trainer.save_model()
        tokenizer.save_pretrained(output_dir)
        
        print(f"✅ Model saved to: {output_dir}")
        
        # 8. Test some translations
        print("\n🧪 Testing fine-tuned model...")
        model.eval()
        
        test_cases = [
            ("Hello", "en_to_lu"),
            ("Good morning", "en_to_lu"),
            ("Shikenu mwani", "lu_to_en")
        ]
        
        for text, direction in test_cases:
            try:
                if direction == "en_to_lu":
                    input_text = f"<EN_TO_LU> {text}"
                else:
                    input_text = f"<LU_TO_EN> {text}"
                
                inputs = tokenizer(
                    input_text,
                    max_length=max_length,
                    padding='max_length',
                    truncation=True,
                    return_tensors='pt'
                )
                
                with torch.no_grad():
                    outputs = model.generate(
                        input_ids=inputs['input_ids'],
                        attention_mask=inputs['attention_mask'],
                        max_length=max_length,
                        num_beams=4,
                        early_stopping=True,
                        pad_token_id=tokenizer.pad_token_id,
                        eos_token_id=tokenizer.eos_token_id,
                        no_repeat_ngram_size=2,
                        length_penalty=1.0
                    )
                
                translation = tokenizer.decode(outputs[0], skip_special_tokens=True)
                print(f"✅ {direction}: '{text}' → '{translation}'")
                
            except Exception as e:
                print(f"❌ Error testing '{text}': {e}")
        
        return model, tokenizer
        
    except Exception as e:
        print(f"❌ Training failed: {e}")
        return None, None

if __name__ == "__main__":
    # Start fine-tuning
    model, tokenizer = fine_tune_bart(
        num_epochs=10,  # Start with 10 epochs
        batch_size=8,   # Smaller batch size for memory
        learning_rate=5e-5
    )
    
    if model is not None:
        print("\n🎉 BART fine-tuning completed successfully!")
        print("🚀 Your model is ready for translations!")
    else:
        print("\n❌ Fine-tuning failed. Check the error messages above.")
