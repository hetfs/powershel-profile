# System utilities

# System info
function Get-SystemInfo {
    Write-Host "System Information:" -ForegroundColor Cyan
    Write-Host "  OS: $([Environment]::OSVersion.VersionString)" -ForegroundColor White
    Write-Host "  PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor White
    Write-Host "  User: $env:USERNAME" -ForegroundColor White
}

# Quick admin
function admin {
    Start-Process wt -Verb RunAs
}

# Clear temp
function Clear-Temp {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Temp cleared" -ForegroundColor Green
}

Write-Host "  System module loaded" -ForegroundColor DarkGray
