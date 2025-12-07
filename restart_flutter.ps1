# Flutter App Restart Script - Clears cache and restarts
Write-Host "🔄 Restarting Flutter App..." -ForegroundColor Cyan

# Navigate to Flutter app directory
Set-Location "$PSScriptRoot\zam_trans_app"

# Stop any running Flutter processes
Write-Host "`n⏹️  Stopping any running Flutter processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*flutter*" -or $_.ProcessName -like "*dart*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Clean Flutter build
Write-Host "🧹 Cleaning Flutter build cache..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "📦 Reinstalling dependencies..." -ForegroundColor Yellow
flutter pub get

# Start the app
Write-Host "`n🚀 Starting Flutter app..." -ForegroundColor Green
Write-Host "   This will open in Chrome automatically" -ForegroundColor Gray
Write-Host "   URL: http://localhost:3000" -ForegroundColor Gray
Write-Host "`nPress Ctrl+C to stop the app`n" -ForegroundColor Yellow

flutter run -d chrome --web-port 3000





