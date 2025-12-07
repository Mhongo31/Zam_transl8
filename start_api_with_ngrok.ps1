# PowerShell script to start FastAPI and ngrok together

Write-Host "🚀 Starting Zam Transl8 API with ngrok..." -ForegroundColor Green

# Check if API is already running on port 8001
$existingProcess = Get-NetTCPConnection -LocalPort 8001 -ErrorAction SilentlyContinue
if ($existingProcess) {
    Write-Host "⚠️  Port 8001 is already in use. Stopping existing process..." -ForegroundColor Yellow
    $processId = $existingProcess.OwningProcess
    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Navigate to project directory
$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectDir

# Check if ngrok is available (look in current directory first, then PATH)
$ngrokPath = Join-Path $projectDir "ngrok.exe"
if (-not (Test-Path $ngrokPath)) {
    $ngrokPath = Get-Command ngrok -ErrorAction SilentlyContinue
    if ($ngrokPath) {
        $ngrokPath = $ngrokPath.Source
    }
}

if (-not $ngrokPath -or -not (Test-Path $ngrokPath)) {
    Write-Host "❌ ngrok not found!" -ForegroundColor Red
    Write-Host "Please install ngrok:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://ngrok.com/download" -ForegroundColor Yellow
    Write-Host "2. Extract ngrok.exe to this folder: $projectDir" -ForegroundColor Yellow
    Write-Host "3. (Optional) Sign up at https://dashboard.ngrok.com for stable URLs" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found ngrok at: $ngrokPath" -ForegroundColor Green

# Start FastAPI in background
Write-Host "📡 Starting FastAPI server on port 8001..." -ForegroundColor Cyan
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:projectDir
    python api.py
}

# Wait a moment for API to start
Start-Sleep -Seconds 3

# Check if API started successfully
$apiRunning = Get-NetTCPConnection -LocalPort 8001 -ErrorAction SilentlyContinue
if (-not $apiRunning) {
    Write-Host "❌ API failed to start. Check for errors above." -ForegroundColor Red
    Stop-Job $apiJob
    Remove-Job $apiJob
    exit 1
}

Write-Host "✅ API is running on http://localhost:8001" -ForegroundColor Green

# Start ngrok
Write-Host "🌐 Starting ngrok tunnel..." -ForegroundColor Cyan
Write-Host "Your public URL will appear below:" -ForegroundColor Yellow
Write-Host ""

# Start ngrok (this will run in foreground and show the URL)
& $ngrokPath http 8001

# Cleanup when ngrok is stopped (Ctrl+C)
Write-Host "`n🛑 Stopping API..." -ForegroundColor Yellow
Stop-Job $apiJob
Remove-Job $apiJob
Write-Host "✅ Cleaned up. Goodbye!" -ForegroundColor Green

