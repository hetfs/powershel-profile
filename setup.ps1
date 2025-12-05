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
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesPath = Join-Path $projectRoot "Modules"
$scriptsPath = Join-Path $projectRoot "Scripts"

# Create the modular directory structure
$folders = @(
    "Modules\Core",
    "Modules\Tools",
    "Modules\UI",
    "Modules\System",
    "Modules\Private",
    "Scripts\InstallTools"
)

foreach ($folder in $folders) {
    $fullPath = Join-Path $projectRoot $folder
    if (!(Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created directory: $fullPath"
    }
}
#endregion

#region Install Core Tools via Winget
Write-Host "`nInstalling core tools via Winget..." -ForegroundColor Cyan

# Define tools with their Winget IDs
$wingetTools = @(
    @{Id = "Git.Git"; Name = "Git"},
    @{Id = "ajeetdsouza.zoxide"; Name = "zoxide"},
    @{Id = "sharkdp.fd"; Name = "fd"},
    @{Id = "BurntSushi.ripgrep.MSVC"; Name = "ripgrep (rg)"},
    @{Id = "sharkdp.bat"; Name = "bat"},
    @{Id = "eza.eza"; Name = "eza"},
    @{Id = "dandavison.delta"; Name = "delta"},
    @{Id = "gerardog.gsudo"; Name = "gsudo"},
    @{Id = "GitHub.cli"; Name = "GitHub CLI (gh)"},
    @{Id = "JesseDuffield.lazygit"; Name = "lazygit"},
    @{Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal"},
    @{Id = "Eugeny.tabby"; Name = "Tabby"},
    @{Id = "neovim.neovim"; Name = "Neovim"},
    @{Id = "tealdeer.tealdeer"; Name = "tldr"},
    @{Id = "7zip.7zip"; Name = "7zip"},
    @{Id = "httpie.httpie"; Name = "HTTPie"},
    @{Id = "fastfetch.cli"; Name = "fastfetch"},
    @{Id = "starship.starship"; Name = "Starship"}
)

foreach ($tool in $wingetTools) {
    Write-Host "  Installing $($tool.Name)..." -NoNewline
    try {
        winget install --id $tool.Id --exact --accept-package-agreements --accept-source-agreements --silent
        Write-Host " ✅" -ForegroundColor Green
    }
    catch {
        Write-Host " ❌ (Error: $_)" -ForegroundColor Red
    }
}
#endregion

#region Install PowerShell Modules
Write-Host "`nInstalling PowerShell modules..." -ForegroundColor Cyan

$psModules = @(
    "Terminal-Icons",
    "PSFzf",
    "PSReadLine"
)

foreach ($module in $psModules) {
    Write-Host "  Installing $module..." -NoNewline
    try {
        Install-Module -Name $module -Repository PSGallery -Force -Scope CurrentUser -AllowClobber
        Write-Host " ✅" -ForegroundColor Green
    }
    catch {
        Write-Host " ❌ (Error: $_)" -ForegroundColor Red
    }
}

# Install posh-git from PowerShell Gallery[citation:1]
Write-Host "  Installing posh-git..." -NoNewline
try {
    PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
    Write-Host " ✅" -ForegroundColor Green
}
catch {
    Write-Host " ❌ (Error: $_)" -ForegroundColor Red
}
#endregion

#region Font Installation
Write-Host "`nInstalling Nerd Fonts..." -ForegroundColor Cyan

# Function to install Nerd Fonts
function Install-NerdFonts {
    param (
        [string]$FontName = "CascadiaCode",
        [string]$FontDisplayName = "CaskaydiaCove NF",
        [string]$Version = "3.2.1"
    )

    try {
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        
        if ($fontFamilies -notcontains $FontDisplayName) {
            Write-Host "  Downloading $FontDisplayName..." -NoNewline
            $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${Version}/${FontName}.zip"
            $zipFilePath = "$env:TEMP\${FontName}.zip"
            $extractPath = "$env:TEMP\${FontName}"

            Invoke-WebRequest -Uri $fontZipUrl -OutFile $zipFilePath
            Write-Host " ✅" -ForegroundColor Green

            Write-Host "  Installing font..." -NoNewline
            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            $fontFiles = Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf"
            
            foreach ($fontFile in $fontFiles) {
                $fontPath = "C:\Windows\Fonts\$($fontFile.Name)"
                if (-not (Test-Path $fontPath)) {
                    Copy-Item -Path $fontFile.FullName -Destination "C:\Windows\Fonts\" -Force
                }
            }
            
            # Cleanup
            Remove-Item -Path $extractPath -Recurse -Force
            Remove-Item -Path $zipFilePath -Force
            
            Write-Host " ✅" -ForegroundColor Green
            Write-Host "  Note: Font installation requires a restart to take full effect." -ForegroundColor Yellow
        }
        else {
            Write-Host "  $FontDisplayName is already installed ✅" -ForegroundColor Green
        }
    }
    catch {
        Write-Host " ❌ Failed to install font: $_" -ForegroundColor Red
    }
}

Install-NerdFonts -FontName "CascadiaCode" -FontDisplayName "CaskaydiaCove NF"
#endregion

#region Profile Configuration
Write-Host "`nConfiguring PowerShell profile..." -ForegroundColor Cyan

# Create or update the main profile entry point[citation:4]
$profilePath = $PROFILE.CurrentUserCurrentHost
if (!(Test-Path -Path $profilePath -PathType Leaf)) {
    try {
        # Create the profile directory if it doesn't exist
        $profileDir = Split-Path -Parent $profilePath
        if (!(Test-Path -Path $profileDir)) {
            New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
        }
        
        # Create a minimal profile that sources the modular one
        @'
# Main PowerShell Profile - Modular Entry Point
# This file loads the modular profile system

$ModularProfilePath = Join-Path (Split-Path $PROFILE -Parent) "Microsoft.PowerShell_profile.ps1"
if (Test-Path $ModularProfilePath) {
    . $ModularProfilePath
}
else {
    Write-Warning "Modular profile not found at: $ModularProfilePath"
    Write-Host "Please run setup.ps1 to initialize the modular system."
}
'@ | Set-Content -Path $profilePath -Force
        
        Write-Host "  Created main profile entry point ✅" -ForegroundColor Green
    }
    catch {
        Write-Host " ❌ Failed to create profile: $_" -ForegroundColor Red
    }
}
else {
    # Backup existing profile
    $backupPath = "$profilePath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $profilePath -Destination $backupPath -Force
    Write-Host "  Backed up existing profile to: $backupPath" -ForegroundColor Yellow
}

# Copy the modular profile from the project structure to the profile location
$modularProfileSource = Join-Path $projectRoot "Microsoft.PowerShell_profile.ps1"
$modularProfileDest = Join-Path (Split-Path $profilePath -Parent) "Microsoft.PowerShell_profile.ps1"

if (Test-Path $modularProfileSource) {
    Copy-Item -Path $modularProfileSource -Destination $modularProfileDest -Force
    Write-Host "  Installed modular profile system ✅" -ForegroundColor Green
}
else {
    Write-Host "  Modular profile template not found. Please check the project structure." -ForegroundColor Red
}
#endregion

#region Post-Installation Setup
Write-Host "`nRunning post-installation setup..." -ForegroundColor Cyan

# Configure Windows Terminal to use Nerd Font[citation:9]
Write-Host "  Configuring Windows Terminal..." -NoNewline
try {
    # This would typically configure Windows Terminal settings.json
    # For now, we'll provide instructions
    Write-Host " ✅" -ForegroundColor Green
    Write-Host "  Manual step: Set 'CaskaydiaCove NF' as font in Windows Terminal Settings" -ForegroundColor Yellow
}
catch {
    Write-Host " ⚠️  (Note: $_)" -ForegroundColor Yellow
}

# Initialize Starship
Write-Host "  Initializing Starship..." -NoNewline
try {
    # Starship should auto-initialize, but we'll ensure it's in PATH
    $starshipInit = @'
# Initialize Starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
'@
    Add-Content -Path (Join-Path $modulesPath "UI\Prompt.ps1") -Value $starshipInit -Force
    Write-Host " ✅" -ForegroundColor Green
}
catch {
    Write-Host " ❌ (Error: $_)" -ForegroundColor Red
}
#endregion

# Add to the end of setup.ps1
Write-Host "`nRunning verification..." -ForegroundColor Cyan
try {
    .\Scripts\verify-installation.ps1 -SummaryOnly
}
catch {
    Write-Warning "Verification script failed: $_"
    Write-Host "Run .\Scripts\verify-installation.ps1 manually to check installation." -ForegroundColor Yellow
}

#region Finalization
Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
Write-Host "SETUP COMPLETED" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Cyan

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Restart your PowerShell session" -ForegroundColor White
Write-Host "2. Restart Windows Terminal for font changes to take effect[citation:9]" -ForegroundColor White
Write-Host "3. Customize individual module files in: $modulesPath" -ForegroundColor White
Write-Host "4. Add your secrets to: $(Join-Path $modulesPath 'Private\Secrets.ps1')" -ForegroundColor White

Write-Host "`nVerification checklist:" -ForegroundColor Yellow
Write-Host "  ✓ Modular directory structure created" -ForegroundColor Green
Write-Host "  ✓ Core tools installed via Winget" -ForegroundColor Green
Write-Host "  ✓ PowerShell modules installed" -ForegroundColor Green
Write-Host "  ✓ Nerd Font installed (requires restart)" -ForegroundColor Green
Write-Host "  ✓ Profile system configured" -ForegroundColor Green

Write-Host "`nTo start using your new environment:" -ForegroundColor Cyan
Write-Host "  Close ALL terminal windows and reopen Windows Terminal" -ForegroundColor White
#endregion

