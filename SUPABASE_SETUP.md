# 🗄️ Supabase Setup Guide for Zam Transl8

## Step 1: Create Supabase Project

1. **Go to [supabase.com](https://supabase.com)**
2. **Click "Start your project"** or "New Project"
3. **Sign in** with GitHub (recommended)
4. **Create a new project:**
   - Organization: Select your personal org
   - Project name: `zam-transl8` (or any name you prefer)
   - Database password: Create a strong password (save it!)
   - Region: Choose closest to your location
5. **Click "Create new project"** (takes 2-3 minutes)

## Step 2: Get Your Credentials

Once your project is ready:

1. **Go to Settings > API** in your Supabase dashboard
2. **Copy these values:**
   - **Project URL** (looks like: `https://your-project-id.supabase.co`)
   - **Service Role Key** (long string starting with `eyJ...`)

## Step 3: Create the Database Tables

1. **Go to SQL Editor** in your Supabase dashboard
2. **Click "New query"**
3. **Copy and paste** the contents of `supabase_schema.sql`
4. **Click "Run"** to execute the SQL

## Step 4: Set Environment Variables

### Option A: Create .env file (Recommended)
Create a `.env` file in your project root:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### Option B: Set environment variables in terminal
```bash
# Windows PowerShell
$env:SUPABASE_URL="https://your-project-id.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY="your_service_role_key_here"

# Windows Command Prompt
set SUPABASE_URL=https://your-project-id.supabase.co
set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

## Step 5: Test Your Setup

Run the test script:
```bash
python test_supabase.py
```

You should see:
- ✅ Supabase client created successfully!
- ✅ Successfully connected to Supabase!
- ✅ Successfully logged test translation!

## Step 6: Start Your API

Once Supabase is working:
```bash
python api.py
```

You should see:
- ✅ Supabase client initialized
- API running on http://0.0.0.0:8001

## Step 7: Test Translation Logging

1. **Make a translation** via your Flutter app
2. **Check the logs** - you should see "Translation completed" messages
3. **Check Supabase** - go to Table Editor > translations to see your data
4. **Test history endpoint**: `GET http://localhost:8001/history`

## Troubleshooting

### ❌ "Missing Supabase credentials"
- Make sure you created the `.env` file with correct values
- Or set environment variables in your terminal

### ❌ "relation 'translations' does not exist"
- Run the SQL from `supabase_schema.sql` in your Supabase SQL Editor

### ❌ "Failed to create Supabase client"
- Check your URL and Service Role Key are correct
- Make sure you copied the full key (it's very long)

### ❌ "Authentication failed"
- Make sure you're using the Service Role Key, not the anon key
- Check that your project is fully initialized (wait a few minutes)

## What's Created

### Tables:
- **`users`** - For future user authentication
- **`translations`** - Stores all translation history
- **`recent_translations`** - View for quick access to last 100 translations

### API Endpoints:
- **`POST /translate`** - Now automatically logs to Supabase
- **`GET /history`** - Get translation history
- **`GET /health`** - Check if Supabase is connected

## Next Steps

Once Supabase is working:
1. **Deploy your API** to Render/Railway with the same environment variables
2. **Deploy your Flutter app** to Vercel
3. **Update Flutter app** to use your deployed API URL instead of localhost

## Need Help?

If you get stuck:
1. Check the Supabase dashboard for any error messages
2. Run `python test_supabase.py` to diagnose issues
3. Check the API logs when you start it with `python api.py`
