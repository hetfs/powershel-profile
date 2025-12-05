# Utility functions
function Update-AllTools {
    Write-Host "Updating tools..." -ForegroundColor Cyan
    winget upgrade --all --silent
}
