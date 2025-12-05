# Microsoft.PowerShell_profile.ps1
# Main entry point for modular PowerShell environment

Write-Host "Loading modular PowerShell environment..." -ForegroundColor Cyan

# Define module paths
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesPath = Join-Path $scriptRoot "Modules"

# Error handling preference
$ErrorActionPreference = "Continue"

#region Load Core Modules
Write-Host "  Loading core modules..." -ForegroundColor DarkGray
$corePath = Join-Path $modulesPath "Core"
Get-ChildItem -Path $corePath -Filter "*.ps1" | ForEach-Object {
    try {
        . $_.FullName
        Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
    }
    catch {
        Write-Warning "Failed to load $($_.Name): $_"
    }
}
#endregion

#region Load UI Modules
Write-Host "  Loading UI modules..." -ForegroundColor DarkGray
$uiPath = Join-Path $modulesPath "UI"

# Load Terminal-Icons before prompt for better visual experience[citation:5]
try {
    Import-Module Terminal-Icons -ErrorAction Stop
    Write-Host "    ✓ Terminal-Icons" -ForegroundColor DarkGray
}
catch {
    Write-Warning "Terminal-Icons module not available. Run setup.ps1 to install."
}

Get-ChildItem -Path $uiPath -Filter "*.ps1" | ForEach-Object {
    try {
        . $_.FullName
        Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
    }
    catch {
        Write-Warning "Failed to load $($_.Name): $_"
    }
}
#endregion

#region Load Tools Modules
Write-Host "  Loading development tools..." -ForegroundColor DarkGray
$toolsPath = Join-Path $modulesPath "Tools"

# Load posh-git for Git integration[citation:1]
try {
    Import-Module posh-git -ErrorAction Stop
    Write-Host "    ✓ posh-git" -ForegroundColor DarkGray
}
catch {
    Write-Warning "posh-git module not available. Git integration limited."
}

Get-ChildItem -Path $toolsPath -Filter "*.ps1" | ForEach-Object {
    try {
        . $_.FullName
        Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
    }
    catch {
        Write-Warning "Failed to load $($_.Name): $_"
    }
}
#endregion

#region Load System Modules
Write-Host "  Loading system utilities..." -ForegroundColor DarkGray
$systemPath = Join-Path $modulesPath "System"
Get-ChildItem -Path $systemPath -Filter "*.ps1" | ForEach-Object {
    try {
        . $_.FullName
        Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
    }
    catch {
        Write-Warning "Failed to load $($_.Name): $_"
    }
}
#endregion

#region Load Private Modules (Optional)
$privatePath = Join-Path $modulesPath "Private"
if (Test-Path $privatePath) {
    Write-Host "  Loading private modules..." -ForegroundColor DarkGray
    Get-ChildItem -Path $privatePath -Filter "*.ps1" | ForEach-Object {
        try {
            . $_.FullName
            Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "Failed to load private module $($_.Name)"
        }
    }
}
#endregion

#region Initialize PSReadLine
try {
    Import-Module PSReadLine -ErrorAction Stop
    
    # Configure PSReadLine options
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    
    Write-Host "    ✓ PSReadLine" -ForegroundColor DarkGray
}
catch {
    Write-Warning "PSReadLine module not available. Limited line editing features."
}
#endregion

#region Final Initialization
Write-Host "`nEnvironment ready!" -ForegroundColor Green
Write-Host "Modules loaded from: $modulesPath" -ForegroundColor DarkGray
Write-Host "Customize your environment by editing files in the Modules directory." -ForegroundColor DarkGray

# Display quick status
try {
    $gitVersion = git --version
    Write-Host "`nGit: $gitVersion" -ForegroundColor DarkGray
}
catch {
    Write-Host "`nGit: Not available" -ForegroundColor DarkGray
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Write-Host "Starship: Ready" -ForegroundColor DarkGray
}
else {
    Write-Host "Starship: Not found" -ForegroundColor Yellow
}
#endregion
