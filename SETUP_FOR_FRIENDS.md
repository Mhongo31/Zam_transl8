# 🚀 Quick Setup Guide - Share Your App with Friends

## **4 Terminals You Need Running:**

### **Terminal 1: FastAPI Backend**
```powershell
python api.py
```
✅ Keep this running - your model needs to stay loaded

### **Terminal 2: ngrok for API (port 8001)**
```powershell
.\ngrok.exe http 8001
```
✅ Keep this running - this tunnels your API

### **Terminal 3: Flutter Web App**
```powershell
cd zam_trans_app
flutter run -d chrome --web-port 3000
```
✅ Keep this running - this serves your Flutter app

### **Terminal 4: ngrok for Flutter App (port 3000)**
```powershell
.\ngrok.exe http 3000
```
✅ Keep this running - this makes your Flutter app public

## **What Your Friends Will See:**

1. **Flutter App URL** (from Terminal 4): `https://some-url.ngrok-free.app`
   - This is what you share with friends
   - They open this in their browser
   - They see your Flutter app

2. **API URL** (from Terminal 2): `https://examiningly-stealthy-elijah.ngrok-free.dev`
   - Already configured in your Flutter app
   - Friends don't need to know this
   - The app uses it automatically

## **Important Notes:**

⚠️ **Keep all 4 terminals running** - if you close any, that part stops working

⚠️ **Keep your PC on** - everything runs on your PC

⚠️ **URLs change** - if you restart ngrok, you get new URLs (need to update Flutter app if API URL changes)

## **Troubleshooting:**

- **Flutter app not loading?** Check Terminal 3 for errors
- **Translations not working?** Check Terminal 1 (API) and Terminal 2 (API ngrok)
- **Friends can't access?** Check Terminal 4 (Flutter ngrok) is running

