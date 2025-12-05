# setup.ps1 - Modular PowerShell Environment Installer
# Run from: Documents\PowerShell\

#region Prerequisites
# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    break
}
#endregion

#region Project Structure Creation
Write-Host "📁 Creating project structure..." -ForegroundColor Cyan

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesPath = Join-Path $projectRoot "Modules"

# Create the modular directory structure
$folders = @(
    "Modules\Core",
    "Modules\Tools",
    "Modules\UI",
    "Modules\System",
    "Modules\Private",
    "Scripts"
)

foreach ($folder in $folders) {
    $fullPath = Join-Path $projectRoot $folder
    if (!(Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "  ✓ Created: $folder" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Already exists: $folder" -ForegroundColor Gray
    }
}
#endregion

#region Install Core Tools via Winget
Write-Host "`n📦 Installing core tools via Winget..." -ForegroundColor Cyan

# Define tools with their Winget IDs
$wingetTools = @(
    @{Id = "Git.Git"; Name = "Git"},
    @{Id = "ajeetdsouza.zoxide"; Name = "zoxide"},
    @{Id = "sharkdp.fd"; Name = "fd"},
    @{Id = "BurntSushi.ripgrep.MSVC"; Name = "ripgrep"},
    @{Id = "sharkdp.bat"; Name = "bat"},
    @{Id = "eza.eza"; Name = "eza"},
    @{Id = "dandavison.delta"; Name = "delta"},
    @{Id = "gerardog.gsudo"; Name = "gsudo"},
    @{Id = "GitHub.cli"; Name = "GitHub CLI"},
    @{Id = "JesseDuffield.lazygit"; Name = "lazygit"},
    @{Id = "starship.starship"; Name = "Starship"},
    @{Id = "neovim.neovim"; Name = "Neovim"},
    @{Id = "tealdeer.tealdeer"; Name = "tldr"}
)

$installedCount = 0
foreach ($tool in $wingetTools) {
    Write-Host "  Installing $($tool.Name)..." -NoNewline -ForegroundColor Gray
    try {
        # Check if already installed
        $installed = winget list --id $tool.Id 2>$null | Select-String $tool.Id
        if ($installed) {
            Write-Host " ✓ Already installed" -ForegroundColor Gray
            $installedCount++
        } else {
            winget install --id $tool.Id --exact --accept-package-agreements --accept-source-agreements --silent
            Write-Host " ✓ Installed" -ForegroundColor Green
            $installedCount++
        }
    }
    catch {
        Write-Host " ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host "  $installedCount/$($wingetTools.Count) tools installed" -ForegroundColor Cyan
#endregion

#region Install PowerShell Modules
Write-Host "`n🔌 Installing PowerShell modules..." -ForegroundColor Cyan

$psModules = @(
    "Terminal-Icons",
    "PSFzf",
    "PSReadLine"
)

foreach ($module in $psModules) {
    Write-Host "  Installing $module..." -NoNewline -ForegroundColor Gray
    try {
        # Check if module is already installed
        if (Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue) {
            Write-Host " ✓ Already installed" -ForegroundColor Gray
        } else {
            Install-Module -Name $module -Repository PSGallery -Force -Scope CurrentUser -AllowClobber
            Write-Host " ✓ Installed" -ForegroundColor Green
        }
    }
    catch {
        Write-Host " ✗ Failed: $_" -ForegroundColor Red
    }
}

# Install posh-git (handles differently)
Write-Host "  Installing posh-git..." -NoNewline -ForegroundColor Gray
try {
    if (Get-Module -ListAvailable -Name posh-git -ErrorAction SilentlyContinue) {
        Write-Host " ✓ Already installed" -ForegroundColor Gray
    } else {
        PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
        Write-Host " ✓ Installed" -ForegroundColor Green
    }
}
catch {
    Write-Host " ✗ Failed: $_" -ForegroundColor Red
}
#endregion

#region Font Installation
Write-Host "`n🔤 Installing Nerd Fonts..." -ForegroundColor Cyan

function Install-NerdFonts {
    try {
        # Check if font is already installed
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        
        if ($fontFamilies -notcontains "CaskaydiaCove NF") {
            Write-Host "  Downloading CaskaydiaCove NF..." -NoNewline -ForegroundColor Gray
            $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
            $zipPath = "$env:TEMP\CascadiaCode.zip"
            $extractPath = "$env:TEMP\CascadiaCode"
            
            Invoke-WebRequest -Uri $fontUrl -OutFile $zipPath
            Write-Host " ✓ Downloaded" -ForegroundColor Green
            
            Write-Host "  Installing font..." -NoNewline -ForegroundColor Gray
            Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
            Get-ChildItem -Path $extractPath -Filter "*.ttf" | ForEach-Object {
                $fontName = $_.Name
                $fontDest = "C:\Windows\Fonts\$fontName"
                if (-not (Test-Path $fontDest)) {
                    Copy-Item -Path $_.FullName -Destination "C:\Windows\Fonts\" -Force
                }
            }
            
            # Cleanup
            Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
            
            Write-Host " ✓ Installed" -ForegroundColor Green
            Write-Host "  Note: Restart terminals to use the new font" -ForegroundColor Yellow
        } else {
            Write-Host "  ✓ CaskaydiaCove NF already installed" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host " ✗ Font installation failed: $_" -ForegroundColor Red
    }
}

Install-NerdFonts
#endregion

#region Create Default Module Files
Write-Host "`n📄 Creating default module files..." -ForegroundColor Cyan

# Create minimal module files
$coreModules = @(
    @{Name = "Configuration.ps1"; Content = @'
# Configuration settings
$MaximumHistoryCount = 10000
$PSNativeCommandUseErrorActionPreference = $true
'@},
    @{Name = "Aliases.ps1"; Content = @'
# Common aliases
Set-Alias ll Get-ChildItem
Set-Alias grep findstr
Set-Alias which Get-Command
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
'@},
    @{Name = "Functions.ps1"; Content = @'
# Utility functions
function Update-AllTools {
    Write-Host "Updating tools..." -ForegroundColor Cyan
    winget upgrade --all --silent
}
'@}
)

$uiModules = @(
    @{Name = "Prompt.ps1"; Content = @'
# Starship prompt initialization
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
'@},
    @{Name = "Completion.ps1"; Content = @'
# PSFzf integration
try {
    Import-Module PSFzf -ErrorAction Stop
} catch {
    Write-Host "PSFzf not available" -ForegroundColor Gray
}
'@}
)

$toolsModules = @(
    @{Name = "Git.ps1"; Content = @'
# Git shortcuts
function gs { git status }
function ga { git add . }
function gc { git commit -m $args }
function gpush { git push }
function gpull { git pull }
'@}
)

$systemModules = @(
    @{Name = "Updates.ps1"; Content = @'
# Update functions
function Update-PowerShell {
    winget upgrade Microsoft.PowerShell --silent
}
'@}
)

# Helper function to create module files
function Create-ModuleFile {
    param($Path, $Name, $Content)
    $fullPath = Join-Path $Path $Name
    if (!(Test-Path $fullPath)) {
        $Content | Out-File -FilePath $fullPath -Encoding UTF8
        Write-Host "  ✓ Created: $Name" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Already exists: $Name" -ForegroundColor Gray
    }
}

# Create Core modules
Write-Host "  Creating Core modules..." -ForegroundColor Gray
foreach ($module in $coreModules) {
    Create-ModuleFile -Path (Join-Path $modulesPath "Core") -Name $module.Name -Content $module.Content
}

# Create UI modules
Write-Host "  Creating UI modules..." -ForegroundColor Gray
foreach ($module in $uiModules) {
    Create-ModuleFile -Path (Join-Path $modulesPath "UI") -Name $module.Name -Content $module.Content
}

# Create Tools modules
Write-Host "  Creating Tools modules..." -ForegroundColor Gray
foreach ($module in $toolsModules) {
    Create-ModuleFile -Path (Join-Path $modulesPath "Tools") -Name $module.Name -Content $module.Content
}

# Create System modules
Write-Host "  Creating System modules..." -ForegroundColor Gray
foreach ($module in $systemModules) {
    Create-ModuleFile -Path (Join-Path $modulesPath "System") -Name $module.Name -Content $module.Content
}
#endregion

#region Profile Configuration
Write-Host "`n⚡ Configuring PowerShell profile..." -ForegroundColor Cyan

# Copy the main profile
$profileSource = Join-Path $projectRoot "Microsoft.PowerShell_profile.ps1"
if (Test-Path $profileSource) {
    Write-Host "  ✓ Using existing profile" -ForegroundColor Green
} else {
    # Create a basic profile if none exists
    $basicProfile = @'
# PowerShell Profile - Modular Edition
Write-Host "PowerShell profile loaded" -ForegroundColor Green
'@
    $basicProfile | Out-File -FilePath $profileSource -Encoding UTF8
    Write-Host "  ✓ Created basic profile" -ForegroundColor Green
}

# Ensure the profile is set
try {
    # Copy to the standard profile location
    $profilePath = $PROFILE.CurrentUserCurrentHost
    Copy-Item -Path $profileSource -Destination $profilePath -Force
    Write-Host "  ✓ Profile configured at: $profilePath" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Profile configuration failed: $_" -ForegroundColor Red
}
#endregion

#region Finalization
Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
Write-Host "✅ SETUP COMPLETED" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Cyan

Write-Host "`n📋 Summary:" -ForegroundColor Yellow
Write-Host "  • Project structure created" -ForegroundColor White
Write-Host "  • $installedCount tools installed" -ForegroundColor White
Write-Host "  • PowerShell modules installed" -ForegroundColor White
Write-Host "  • Font installed (requires terminal restart)" -ForegroundColor White
Write-Host "  • Profile configured" -ForegroundColor White

Write-Host "`n🚀 Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart PowerShell or Windows Terminal" -ForegroundColor White
Write-Host "  2. Run: .\Scripts\verify-installation.ps1" -ForegroundColor White
Write-Host "  3. Customize modules in: $modulesPath" -ForegroundColor White

Write-Host "`n⚠️  Important:" -ForegroundColor Cyan
Write-Host "  • Set Windows Terminal font to 'CaskaydiaCove NF'" -ForegroundColor White
Write-Host "  • Run verification script to fix any remaining issues" -ForegroundColor White
#endregion
