# ngrok Setup Guide

## Step 1: Download ngrok

1. Go to: https://ngrok.com/download
2. Download the Windows version
3. Extract `ngrok.exe` to a folder (e.g., `C:\ngrok\`)
4. Add that folder to your PATH, OR place `ngrok.exe` in your project folder

## Step 2: Sign up for free ngrok account (optional but recommended)

1. Go to: https://dashboard.ngrok.com/signup
2. Sign up for free account
3. Get your authtoken from: https://dashboard.ngrok.com/get-started/your-authtoken
4. Run: `ngrok config add-authtoken YOUR_TOKEN_HERE`

This gives you:
- Stable URLs (won't change every restart)
- More connections
- Better reliability

## Step 3: Start your API and ngrok

Use the scripts provided:
- `start_api_with_ngrok.ps1` - Starts both API and ngrok together

Or manually:
1. Start API: `python api.py` (runs on port 8001)
2. Start ngrok: `ngrok http 8001`

## Step 4: Get your public URL

After starting ngrok, you'll see:
```
Forwarding: https://abc123.ngrok-free.app -> http://localhost:8001
```

Use that `https://abc123.ngrok-free.app` URL in your Flutter app!

## Step 5: Update Flutter app

Update `zam_trans_app/lib/providers/translation_provider.dart`:
- Change `baseUrl` to your ngrok URL

## Troubleshooting

- **Port 8001 already in use?** Use `start_api.ps1` to kill existing processes
- **ngrok not found?** Make sure ngrok.exe is in your PATH or project folder
- **Connection refused?** Make sure your API is running first

