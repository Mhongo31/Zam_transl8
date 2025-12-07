@echo off
REM Batch script to start FastAPI and ngrok together

echo 🚀 Starting Zam Transl8 API with ngrok...

REM Check if ngrok exists
where ngrok >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ngrok not found!
    echo Please install ngrok:
    echo 1. Download from: https://ngrok.com/download
    echo 2. Extract ngrok.exe to this folder OR add to PATH
    echo 3. (Optional) Sign up at https://dashboard.ngrok.com for stable URLs
    pause
    exit /b 1
)

REM Navigate to script directory
cd /d "%~dp0"

REM Check if port 8001 is in use and kill it
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8001 ^| findstr LISTENING') do (
    echo ⚠️  Port 8001 is in use. Stopping process...
    taskkill /F /PID %%a >nul 2>&1
    timeout /t 2 >nul
)

REM Start FastAPI in background
echo 📡 Starting FastAPI server on port 8001...
start "FastAPI Server" /min python api.py

REM Wait for API to start
timeout /t 3 >nul

REM Start ngrok
echo 🌐 Starting ngrok tunnel...
echo Your public URL will appear below:
echo.
ngrok http 8001

REM Cleanup
echo.
echo 🛑 Stopping API...
taskkill /F /FI "WINDOWTITLE eq FastAPI Server*" >nul 2>&1
echo ✅ Cleaned up. Goodbye!
pause

