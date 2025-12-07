# PowerShell script to start everything for sharing with friends

Write-Host "🚀 Starting Zam Transl8 - Full Setup for Friends" -ForegroundColor Green
Write-Host ""

# Navigate to project directory
$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectDir

# Check if port 8001 is in use (API)
$apiRunning = Get-NetTCPConnection -LocalPort 8001 -ErrorAction SilentlyContinue
if (-not $apiRunning) {
    Write-Host "📡 Starting FastAPI on port 8001..." -ForegroundColor Cyan
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectDir'; python api.py" -WindowStyle Normal
    Write-Host "⏳ Waiting for API to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
} else {
    Write-Host "✅ API is already running on port 8001" -ForegroundColor Green
}

# Check if port 3000 is in use (Flutter)
$flutterRunning = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
if (-not $flutterRunning) {
    Write-Host "📱 Starting Flutter web on port 3000..." -ForegroundColor Cyan
    $flutterDir = Join-Path $projectDir "zam_trans_app"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$flutterDir'; flutter run -d chrome --web-port 3000" -WindowStyle Normal
    Write-Host "⏳ Waiting for Flutter to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
} else {
    Write-Host "✅ Flutter is already running on port 3000" -ForegroundColor Green
}

# Check if ngrok.yml exists
$ngrokConfig = Join-Path $projectDir "ngrok.yml"
if (-not (Test-Path $ngrokConfig)) {
    Write-Host "❌ ngrok.yml not found!" -ForegroundColor Red
    exit 1
}

# Check if ngrok.exe exists
$ngrokPath = Join-Path $projectDir "ngrok.exe"
if (-not (Test-Path $ngrokPath)) {
    Write-Host "❌ ngrok.exe not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🌐 Starting ngrok with both tunnels (API + Flutter)..." -ForegroundColor Cyan
Write-Host "This will open a new window with ngrok running both tunnels" -ForegroundColor Yellow
Write-Host ""

# Start ngrok with config file (runs both tunnels)
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectDir'; & '$ngrokPath' start --all --config='$ngrokConfig'" -WindowStyle Normal

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 What's running:" -ForegroundColor Cyan
Write-Host "  - Terminal 1: FastAPI (port 8001)" -ForegroundColor White
Write-Host "  - Terminal 2: Flutter Web (port 3000)" -ForegroundColor White
Write-Host "  - Terminal 3: ngrok (both tunnels)" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Check the ngrok window for your public URLs:" -ForegroundColor Yellow
Write-Host "  - API URL: https://...ngrok-free.app (for port 8001)" -ForegroundColor White
Write-Host "  - Flutter URL: https://...ngrok-free.app (for port 3000) ← Share this with friends!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Tip: Open http://127.0.0.1:4040 in your browser to see ngrok dashboard" -ForegroundColor Cyan

