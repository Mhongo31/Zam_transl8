# 🚀 Quick ngrok Setup (5 minutes)

## Step 1: Download ngrok ⬇️

1. Go to: **https://ngrok.com/download**
2. Download **Windows** version
3. Extract `ngrok.exe` to your project folder: `C:\Users\BRIAN MHONGO\Downloads\Projects\Zam_transl8\`

## Step 2: (Optional) Get free ngrok account for stable URLs

1. Sign up: **https://dashboard.ngrok.com/signup** (free)
2. Get your token: **https://dashboard.ngrok.com/get-started/your-authtoken**
3. Run this command:
   ```powershell
   ngrok config add-authtoken YOUR_TOKEN_HERE
   ```

## Step 3: Start everything 🎯

**Option A: Use the helper script (easiest)**
```powershell
.\start_api_with_ngrok.ps1
```

**Option B: Manual (two terminals)**

Terminal 1 - Start API:
```powershell
python api.py
```

Terminal 2 - Start ngrok:
```powershell
ngrok http 8001
```

## Step 4: Get your public URL 🌐

After starting ngrok, you'll see something like:
```
Forwarding: https://abc123.ngrok-free.app -> http://localhost:8001
```

**Copy that URL!** (e.g., `https://abc123.ngrok-free.app`)

## Step 5: Update Flutter app 📱

Update `zam_trans_app/lib/providers/translation_provider.dart` line 71:

**Change from:**
```dart
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8001');
```

**Change to:**
```dart
const String baseUrl = 'YOUR_NGROK_URL_HERE'; // e.g., 'https://abc123.ngrok-free.app'
```

Or run Flutter with:
```powershell
flutter run -d chrome --dart-define=API_BASE_URL=https://abc123.ngrok-free.app
```

## Step 6: Test! ✅

1. Start your Flutter app
2. Try translating something
3. Share the ngrok URL with others - they can use your app!

## ⚠️ Important Notes:

- **Keep your PC on** - ngrok only works when your PC is running
- **URL changes** - If you restart ngrok without an account, you get a new URL
- **Free tier limits** - 40 connections/minute (usually enough for testing)

## 🛑 To Stop:

Press `Ctrl+C` in the terminal running ngrok (and API if running manually)

