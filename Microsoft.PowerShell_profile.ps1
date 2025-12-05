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
if (Test-Path $corePath) {
    Get-ChildItem -Path $corePath -Filter "*.ps1" | ForEach-Object {
        try {
            . $_.FullName
            Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "Failed to load $($_.Name): $_"
        }
    }
} else {
    Write-Host "    ⚠ Core directory not found: $corePath" -ForegroundColor Yellow
    Write-Host "    Run .\setup.ps1 to create the modular structure" -ForegroundColor DarkGray
}
#endregion

#region Load UI Modules
Write-Host "  Loading UI modules..." -ForegroundColor DarkGray
$uiPath = Join-Path $modulesPath "UI"

# Load Terminal-Icons before prompt for better visual experience
try {
    Import-Module Terminal-Icons -ErrorAction Stop
    Write-Host "    ✓ Terminal-Icons" -ForegroundColor DarkGray
}
catch {
    Write-Warning "Terminal-Icons module not available. Run setup.ps1 to install."
}

if (Test-Path $uiPath) {
    Get-ChildItem -Path $uiPath -Filter "*.ps1" | ForEach-Object {
        try {
            . $_.FullName
            Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "Failed to load $($_.Name): $_"
        }
    }
} else {
    Write-Host "    ⚠ UI directory not found: $uiPath" -ForegroundColor Yellow
}
#endregion

#region Load Tools Modules
Write-Host "  Loading development tools..." -ForegroundColor DarkGray
$toolsPath = Join-Path $modulesPath "Tools"

# Load posh-git for Git integration
try {
    Import-Module posh-git -ErrorAction Stop
    Write-Host "    ✓ posh-git" -ForegroundColor DarkGray
}
catch {
    Write-Warning "posh-git module not available. Git integration limited."
}

if (Test-Path $toolsPath) {
    Get-ChildItem -Path $toolsPath -Filter "*.ps1" | ForEach-Object {
        try {
            . $_.FullName
            Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "Failed to load $($_.Name): $_"
        }
    }
} else {
    Write-Host "    ⚠ Tools directory not found: $toolsPath" -ForegroundColor Yellow
}
#endregion

#region Load System Modules
Write-Host "  Loading system utilities..." -ForegroundColor DarkGray
$systemPath = Join-Path $modulesPath "System"
if (Test-Path $systemPath) {
    Get-ChildItem -Path $systemPath -Filter "*.ps1" | ForEach-Object {
        try {
            . $_.FullName
            Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "Failed to load $($_.Name): $_"
        }
    }
} else {
    Write-Host "    ⚠ System directory not found: $systemPath" -ForegroundColor Yellow
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
} else {
    Write-Host "    ℹ Private directory not found (optional): $privatePath" -ForegroundColor DarkGray
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

#region Initialize PSFzf (if available)
try {
    Import-Module PSFzf -ErrorAction Stop
    Write-Host "    ✓ PSFzf" -ForegroundColor DarkGray
}
catch {
    Write-Host "    ℹ PSFzf module not available (optional)" -ForegroundColor DarkGray
}
#endregion

#region Initialize Starship Prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    try {
        Invoke-Expression (&starship init powershell)
        Write-Host "    ✓ Starship prompt initialized" -ForegroundColor DarkGray
    }
    catch {
        Write-Warning "Failed to initialize Starship prompt: $_"
    }
} else {
    Write-Host "    ⚠ Starship not found. Install with: winget install starship.starship" -ForegroundColor Yellow
}
#endregion

#region Final Initialization
Write-Host "`nEnvironment ready!" -ForegroundColor Green
Write-Host "Modules loaded from: $modulesPath" -ForegroundColor DarkGray
Write-Host "Customize your environment by editing files in the Modules directory." -ForegroundColor DarkGray

# Display quick status
$modulesLoaded = 0
if (Test-Path $corePath) { $modulesLoaded += (Get-ChildItem -Path $corePath -Filter "*.ps1").Count }
if (Test-Path $uiPath) { $modulesLoaded += (Get-ChildItem -Path $uiPath -Filter "*.ps1").Count }
if (Test-Path $toolsPath) { $modulesLoaded += (Get-ChildItem -Path $toolsPath -Filter "*.ps1").Count }
if (Test-Path $systemPath) { $modulesLoaded += (Get-ChildItem -Path $systemPath -Filter "*.ps1").Count }

Write-Host "`nModules loaded: $modulesLoaded" -ForegroundColor DarkGray

try {
    $gitVersion = (git --version 2>$null) -replace 'git version ', ''
    Write-Host "Git: v$gitVersion" -ForegroundColor DarkGray
}
catch {
    Write-Host "Git: Not available" -ForegroundColor DarkGray
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Write-Host "Starship: Ready" -ForegroundColor DarkGray
} else {
    Write-Host "Starship: Not found" -ForegroundColor Yellow
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Write-Host "zoxide: Ready" -ForegroundColor DarkGray
} else {
    Write-Host "zoxide: Not found" -ForegroundColor DarkGray
}

# Helpful tips if directories are missing
$missingDirs = @()
if (-not (Test-Path $corePath)) { $missingDirs += "Core" }
if (-not (Test-Path $uiPath)) { $missingDirs += "UI" }
if (-not (Test-Path $toolsPath)) { $missingDirs += "Tools" }
if (-not (Test-Path $systemPath)) { $missingDirs += "System" }

if ($missingDirs.Count -gt 0) {
    Write-Host "`nMissing module directories: $($missingDirs -join ', ')" -ForegroundColor Yellow
    Write-Host "Run .\setup.ps1 to create the complete modular structure" -ForegroundColor Cyan
}
#endregion
