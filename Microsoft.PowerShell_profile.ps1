# Microsoft.PowerShell_profile.ps1
# Main entry point for modular PowerShell environment

Write-Host "Loading modular PowerShell environment..." -ForegroundColor Cyan

# Define module paths
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesPath = Join-Path $scriptRoot "Modules"

# Error handling preference
$ErrorActionPreference = "Continue"

#region Auto-Create Missing Module Directories
Write-Host "  Checking module structure..." -ForegroundColor DarkGray

# Define required module directories
$requiredDirectories = @(
    @{Path = "Core"; Description = "Essential functionality"},
    @{Path = "UI"; Description = "User interface"},
    @{Path = "Tools"; Description = "Development tools"},
    @{Path = "System"; Description = "System utilities"},
    @{Path = "Private"; Description = "Private data (optional)"}
)

$createdDirectories = 0
$missingDirectories = @()

foreach ($dirInfo in $requiredDirectories) {
    $fullPath = Join-Path $modulesPath $dirInfo.Path
    
    if (-not (Test-Path $fullPath)) {
        $missingDirectories += $dirInfo.Path
        
        # Create the directory
        try {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
            Write-Host "    ✓ Created: $($dirInfo.Path) ($($dirInfo.Description))" -ForegroundColor Green
            $createdDirectories++
            
            # Create a starter file for Core, UI, Tools, System
            if ($dirInfo.Path -ne "Private") {
                $starterFile = Join-Path $fullPath "$($dirInfo.Path).ps1"
                $starterContent = @"
# $($dirInfo.Description)
# Add your $($dirInfo.Path.ToLower()) functions and aliases here

Write-Host "  $($dirInfo.Path) module loaded" -ForegroundColor DarkGray
"@
                $starterContent | Out-File -FilePath $starterFile -Encoding UTF8
            }
        }
        catch {
            Write-Host "    ⚠ Failed to create: $($dirInfo.Path)" -ForegroundColor Red
        }
    } else {
        Write-Host "    ✓ Found: $($dirInfo.Path)" -ForegroundColor Gray
    }
}

if ($createdDirectories -gt 0) {
    Write-Host "    Created $createdDirectories missing directories" -ForegroundColor Cyan
}
#endregion

#region Load Core Modules
Write-Host "`n  Loading core modules..." -ForegroundColor DarkGray
$corePath = Join-Path $modulesPath "Core"
if (Test-Path $corePath) {
    $coreFiles = Get-ChildItem -Path $corePath -Filter "*.ps1" -ErrorAction SilentlyContinue
    if ($coreFiles) {
        $coreFiles | ForEach-Object {
            try {
                . $_.FullName
                Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "    ⚠ Failed to load $($_.Name): $_" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "    ℹ No module files found in Core directory" -ForegroundColor Gray
    }
} else {
    Write-Host "    ⚠ Core directory not found" -ForegroundColor Yellow
}
#endregion

#region Load UI Modules
Write-Host "  Loading UI modules..." -ForegroundColor DarkGray
$uiPath = Join-Path $modulesPath "UI"

# Load Terminal-Icons before prompt for better visual experience
try {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
    Write-Host "    ✓ Terminal-Icons" -ForegroundColor DarkGray
}
catch {
    Write-Host "    ℹ Terminal-Icons not available (optional)" -ForegroundColor Gray
}

if (Test-Path $uiPath) {
    $uiFiles = Get-ChildItem -Path $uiPath -Filter "*.ps1" -ErrorAction SilentlyContinue
    if ($uiFiles) {
        $uiFiles | ForEach-Object {
            try {
                . $_.FullName
                Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "    ⚠ Failed to load $($_.Name): $_" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "    ℹ No module files found in UI directory" -ForegroundColor Gray
    }
} else {
    Write-Host "    ⚠ UI directory not found" -ForegroundColor Yellow
}
#endregion

#region Load Tools Modules
Write-Host "  Loading development tools..." -ForegroundColor DarkGray
$toolsPath = Join-Path $modulesPath "Tools"

# Load posh-git for Git integration
try {
    Import-Module posh-git -ErrorAction SilentlyContinue
    Write-Host "    ✓ posh-git" -ForegroundColor DarkGray
}
catch {
    Write-Host "    ℹ posh-git not available (optional)" -ForegroundColor Gray
}

if (Test-Path $toolsPath) {
    $toolsFiles = Get-ChildItem -Path $toolsPath -Filter "*.ps1" -ErrorAction SilentlyContinue
    if ($toolsFiles) {
        $toolsFiles | ForEach-Object {
            try {
                . $_.FullName
                Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "    ⚠ Failed to load $($_.Name): $_" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "    ℹ No module files found in Tools directory" -ForegroundColor Gray
    }
} else {
    Write-Host "    ⚠ Tools directory not found" -ForegroundColor Yellow
}
#endregion

#region Load System Modules
Write-Host "  Loading system utilities..." -ForegroundColor DarkGray
$systemPath = Join-Path $modulesPath "System"
if (Test-Path $systemPath) {
    $systemFiles = Get-ChildItem -Path $systemPath -Filter "*.ps1" -ErrorAction SilentlyContinue
    if ($systemFiles) {
        $systemFiles | ForEach-Object {
            try {
                . $_.FullName
                Write-Host "    ✓ $($_.BaseName)" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "    ⚠ Failed to load $($_.Name): $_" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "    ℹ No module files found in System directory" -ForegroundColor Gray
    }
} else {
    Write-Host "    ⚠ System directory not found" -ForegroundColor Yellow
}
#endregion

#region Initialize Essential Modules
Write-Host "`n  Initializing essential components..." -ForegroundColor DarkGray

# Initialize PSReadLine (essential for good UX)
try {
    Import-Module PSReadLine -ErrorAction Stop
    
    # Configure PSReadLine options
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    
    Write-Host "    ✓ PSReadLine" -ForegroundColor DarkGray
}
catch {
    Write-Host "    ⚠ PSReadLine not available" -ForegroundColor Yellow
}

# Initialize PSFzf (optional but nice to have)
try {
    Import-Module PSFzf -ErrorAction SilentlyContinue
    Write-Host "    ✓ PSFzf" -ForegroundColor DarkGray
}
catch {
    Write-Host "    ℹ PSFzf not available (optional)" -ForegroundColor Gray
}

# Initialize Starship Prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    try {
        Invoke-Expression (&starship init powershell)
        Write-Host "    ✓ Starship prompt" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "    ⚠ Starship initialization failed" -ForegroundColor Yellow
    }
} else {
    Write-Host "    ⚠ Starship not found. Run: winget install starship.starship" -ForegroundColor Yellow
}
#endregion

#region Final Initialization
Write-Host "`nEnvironment ready!" -ForegroundColor Green
Write-Host "Modules loaded from: $modulesPath" -ForegroundColor DarkGray

# Display quick status
$status = @{
    Git = if (Get-Command git -ErrorAction SilentlyContinue) { "✓ v$(git --version 2>$null | ForEach-Object { $_ -replace 'git version ', '' })" } else { "✗ Not found" }
    Starship = if (Get-Command starship -ErrorAction SilentlyContinue) { "✓ Ready" } else { "✗ Not installed" }
    zoxide = if (Get-Command zoxide -ErrorAction SilentlyContinue) { "✓ Ready" } else { "✗ Not found" }
    Font = try { 
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $fonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        if ($fonts -contains "CaskaydiaCove NF") { "✓ Installed" } else { "✗ Missing" }
    } catch { "? Unknown" }
}

Write-Host "`nQuick Status:" -ForegroundColor DarkGray
$status.GetEnumerator() | ForEach-Object {
    $color = if ($_.Value -like "✓*") { "Green" } elseif ($_.Value -like "✗*") { "Red" } else { "Gray" }
    Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor $color
}

# Helpful tips
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Add functions to module files in: $modulesPath" -ForegroundColor White
Write-Host "  2. Install missing tools: Run '.\Scripts\verify-installation.ps1 -Fix' (as admin)" -ForegroundColor White
Write-Host "  3. Set Windows Terminal font to 'CaskaydiaCove NF'" -ForegroundColor White
Write-Host "  4. Run '.\setup.ps1' for complete installation" -ForegroundColor White

# Create a quick help function
function Get-PowerShellHelp {
    Write-Host "`nAvailable help commands:" -ForegroundColor Cyan
    Write-Host "  Get-PowerShellHelp    Show this help" -ForegroundColor White
    Write-Host "  Update-Profile        Update your profile" -ForegroundColor White
    Write-Host "  . `$PROFILE            Reload profile" -ForegroundColor White
}
#endregion
