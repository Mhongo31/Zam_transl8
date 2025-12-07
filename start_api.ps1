# Stop any existing API servers on port 8001
Write-Host "Stopping any existing API servers on port 8001..." -ForegroundColor Yellow
$processes = netstat -ano | Select-String ":8001" | Select-String "LISTENING"
foreach ($line in $processes) {
    $pid = ($line -split '\s+')[-1]
    if ($pid -match '^\d+$') {
        Write-Host "Stopping process $pid" -ForegroundColor Yellow
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    }
}
Start-Sleep -Seconds 2

# Start the API server
Write-Host "Starting API server..." -ForegroundColor Green
Set-Location $PSScriptRoot
python api.py





