-- Supabase Database Schema for Lunda-English Translation App
-- Run this in your Supabase SQL Editor

-- Create enum for translation direction
CREATE TYPE translation_direction AS ENUM ('en_to_lu', 'lu_to_en');

-- Users table (for future authentication/features)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE,
    name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Translations table (main table for storing translation history)
CREATE TABLE IF NOT EXISTS translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Optional user association
    direction translation_direction NOT NULL,
    source_text TEXT NOT NULL,
    translated_text TEXT NOT NULL,
    latency_ms INTEGER, -- Translation time in milliseconds
    model_checkpoint TEXT DEFAULT 'checkpoint-15000',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_translations_direction ON translations(direction);
CREATE INDEX IF NOT EXISTS idx_translations_created_at ON translations(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_translations_user_id ON translations(user_id);

-- Create a view for recent translations (last 100)
CREATE OR REPLACE VIEW recent_translations AS
SELECT 
    id,
    direction,
    source_text,
    translated_text,
    latency_ms,
    model_checkpoint,
    created_at
FROM translations 
ORDER BY created_at DESC 
LIMIT 100;

-- Enable Row Level Security (RLS) for future user authentication
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE translations ENABLE ROW LEVEL SECURITY;

-- Create policies (for now, allow all operations - adjust when you add auth)
CREATE POLICY "Allow all operations on users" ON users FOR ALL USING (true);
CREATE POLICY "Allow all operations on translations" ON translations FOR ALL USING (true);

-- Grant permissions
GRANT ALL ON users TO authenticated;
GRANT ALL ON translations TO authenticated;
GRANT ALL ON recent_translations TO authenticated;
