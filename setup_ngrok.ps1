# Script to configure ngrok and start everything

Write-Host "🔧 Setting up ngrok..." -ForegroundColor Cyan

# Check if ngrok.exe exists in current directory
$ngrokPath = Join-Path $PSScriptRoot "ngrok.exe"
if (-not (Test-Path $ngrokPath)) {
    Write-Host "❌ ngrok.exe not found in project folder!" -ForegroundColor Red
    Write-Host "Please copy ngrok.exe to: $PSScriptRoot" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Steps:" -ForegroundColor Yellow
    Write-Host "1. Find where you extracted ngrok (usually in Downloads)" -ForegroundColor White
    Write-Host "2. Copy ngrok.exe to this folder: $PSScriptRoot" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    pause
    exit 1
}

Write-Host "✅ Found ngrok.exe" -ForegroundColor Green

# Add authtoken
Write-Host "🔑 Adding authtoken..." -ForegroundColor Cyan
& $ngrokPath config add-authtoken 36WZOaBlAuZ8KIZg3B5Zbw5bam5_4AZnXjD8hdUrU5BTEZ4DW

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Authtoken configured successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Authtoken might already be configured (that's okay)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 Ready to start! Next steps:" -ForegroundColor Green
Write-Host "1. Run: .\start_api_with_ngrok.ps1" -ForegroundColor White
Write-Host "   OR" -ForegroundColor White
Write-Host "2. Start API manually: python api.py" -ForegroundColor White
Write-Host "3. Then in another terminal: .\ngrok.exe http 8001" -ForegroundColor White
Write-Host ""

