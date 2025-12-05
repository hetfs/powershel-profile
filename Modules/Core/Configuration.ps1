# Configuration.ps1 - Environment settings and configuration

# Set PowerShell preferences
Set-StrictMode -Version Latest
$PSNativeCommandUseErrorActionPreference = $true

# Environment variables
$env:PAGER = "delta"
$env:BAT_THEME = "TwoDark"

# PowerShell preferences
$MaximumHistoryCount = 10000

# Custom PowerShell drives (example)[citation:4]
if (!(Test-Path HKCR:)) {
    $null = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
}

# Custom function to update all tools
function Update-AllTools {
    Write-Host "Updating all tools..." -ForegroundColor Cyan
    
    # Update Winget packages
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  Updating Winget packages..." -NoNewline
        winget upgrade --all --silent
        Write-Host " ✓" -ForegroundColor Green
    }
    
    # Update PowerShell modules
    Write-Host "  Updating PowerShell modules..." -NoNewline
    Update-Module -Force -ErrorAction SilentlyContinue
    Write-Host " ✓" -ForegroundColor Green
}
