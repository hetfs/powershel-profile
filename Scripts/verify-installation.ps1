# Scripts/verify-installation.ps1
# Post-installation verification script for Modular PowerShell Environment
# Run this after setup to verify everything installed correctly

param(
    [switch]$Fix,
    [switch]$SummaryOnly
)

Write-Host "🔍 PowerShell Environment Verification" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

# Configuration
$requiredTools = @(
    @{Name = "git"; Display = "Git"; InstallCommand = "winget install Git.Git --silent"},
    @{Name = "starship"; Display = "Starship Prompt"; InstallCommand = "winget install starship.starship --silent"},
    @{Name = "zoxide"; Display = "zoxide"; InstallCommand = "winget install ajeetdsouza.zoxide --silent"},
    @{Name = "rg"; Display = "ripgrep"; InstallCommand = "winget install BurntSushi.ripgrep.MSVC --silent"},
    @{Name = "bat"; Display = "bat"; InstallCommand = "winget install sharkdp.bat --silent"},
    @{Name = "fd"; Display = "fd"; InstallCommand = "winget install sharkdp.fd --silent"},
    @{Name = "eza"; Display = "eza"; InstallCommand = "winget install eza.eza --silent"},
    @{Name = "delta"; Display = "delta"; InstallCommand = "winget install dandavison.delta --silent"},
    @{Name = "gsudo"; Display = "gsudo"; InstallCommand = "winget install gerardog.gsudo --silent"},
    @{Name = "gh"; Display = "GitHub CLI"; InstallCommand = "winget install GitHub.cli --silent"},
    @{Name = "lazygit"; Display = "lazygit"; InstallCommand = "winget install JesseDuffield.lazygit --silent"},
    @{Name = "neovim"; Display = "Neovim"; InstallCommand = "winget install neovim.neovim --silent"},
    @{Name = "tldr"; Display = "tldr"; InstallCommand = "winget install tealdeer.tealdeer --silent"}
)

$requiredModules = @(
    @{Name = "posh-git"; Display = "posh-git"; InstallCommand = "Install-Module -Name posh-git -Scope CurrentUser -Force"},
    @{Name = "Terminal-Icons"; Display = "Terminal-Icons"; InstallCommand = "Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser"},
    @{Name = "PSReadLine"; Display = "PSReadLine"; InstallCommand = "Install-Module -Name PSReadLine -Repository PSGallery -Force -Scope CurrentUser"},
    @{Name = "PSFzf"; Display = "PSFzf"; InstallCommand = "Install-Module -Name PSFzf -Repository PSGallery -Force -Scope CurrentUser"}
)

$requiredFonts = @(
    "CaskaydiaCove NF"
)

# Results tracking
$results = @{
    Tools = @()
    Modules = @()
    Fonts = @()
    Profile = $null
    Structure = $null
}

# Check for admin rights (for fixes)
function Test-Admin {
    $currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check core tools
function Test-CoreTools {
    Write-Host "`n📦 Core Tools Verification:" -ForegroundColor Yellow
    
    foreach ($tool in $requiredTools) {
        $status = $false
        $message = ""
        
        try {
            $cmd = Get-Command $tool.Name -ErrorAction Stop
            $version = & $tool.Name --version 2>$null | Select-Object -First 1
            $status = $true
            $message = "v$version" -replace '\s+', ' '
        }
        catch {
            if ($Fix -and $tool.InstallCommand -and (Test-Admin)) {
                Write-Host "  ⚡ Installing $($tool.Display)..." -NoNewline -ForegroundColor Magenta
                try {
                    Invoke-Expression $tool.InstallCommand
                    $status = $true
                    $message = "Installed"
                    Write-Host " ✓" -ForegroundColor Green
                }
                catch {
                    $message = "Install failed: $_"
                    Write-Host " ✗" -ForegroundColor Red
                }
            }
            else {
                $message = "Not found"
            }
        }
        
        $results.Tools += @{
            Name = $tool.Display
            Status = $status
            Message = $message
            Fixable = ($tool.InstallCommand -ne $null)
        }
        
        if (-not $SummaryOnly) {
            $color = if ($status) { "Green" } else { "Red" }
            $symbol = if ($status) { "✓" } else { "✗" }
            Write-Host "  $symbol $($tool.Display): $message" -ForegroundColor $color
        }
    }
}

# Check PowerShell modules
function Test-PowerShellModules {
    Write-Host "`n🔌 PowerShell Modules Verification:" -ForegroundColor Yellow
    
    foreach ($module in $requiredModules) {
        $status = $false
        $message = ""
        
        try {
            $moduleInfo = Get-Module -Name $module.Name -ListAvailable -ErrorAction Stop | Select-Object -First 1
            if ($moduleInfo) {
                $status = $true
                $message = "v$($moduleInfo.Version)"
            }
            else {
                throw "Module not found"
            }
        }
        catch {
            if ($Fix) {
                Write-Host "  ⚡ Installing $($module.Display) module..." -NoNewline -ForegroundColor Magenta
                try {
                    Invoke-Expression $module.InstallCommand
                    
                    # Verify installation
                    $moduleInfo = Get-Module -Name $module.Name -ListAvailable -ErrorAction SilentlyContinue
                    if ($moduleInfo) {
                        $status = $true
                        $message = "Installed"
                        Write-Host " ✓" -ForegroundColor Green
                    }
                    else {
                        throw "Installation verification failed"
                    }
                }
                catch {
                    $message = "Install failed: $_"
                    Write-Host " ✗" -ForegroundColor Red
                }
            }
            else {
                $message = "Not installed"
            }
        }
        
        $results.Modules += @{
            Name = $module.Display
            Status = $status
            Message = $message
            Fixable = $true
        }
        
        if (-not $SummaryOnly) {
            $color = if ($status) { "Green" } else { "Red" }
            $symbol = if ($status) { "✓" } else { "✗" }
            Write-Host "  $symbol $($module.Display): $message" -ForegroundColor $color
        }
    }
}

# Check font installation
function Test-FontInstallation {
    Write-Host "`n🔤 Font Verification:" -ForegroundColor Yellow
    
    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $fontCollection = New-Object System.Drawing.Text.InstalledFontCollection
        $installedFonts = $fontCollection.Families.Name
    }
    catch {
        Write-Host "  ⚠ Unable to check fonts (requires .NET): $_" -ForegroundColor Yellow
        return
    }
    
    foreach ($font in $requiredFonts) {
        $status = $installedFonts -contains $font
        $message = if ($status) { "Installed" } else { "Not found" }
        
        $results.Fonts += @{
            Name = $font
            Status = $status
            Message = $message
            Fixable = $false
        }
        
        if (-not $SummaryOnly) {
            $color = if ($status) { "Green" } else { "Red" }
            $symbol = if ($status) { "✓" } else { "✗" }
            Write-Host "  $symbol $font: $message" -ForegroundColor $color
        }
    }
}

# Check project structure
function Test-ProjectStructure {
    Write-Host "`n📁 Project Structure Verification:" -ForegroundColor Yellow
    
    $expectedPaths = @(
        "$env:USERPROFILE\Documents\PowerShell",
        "$env:USERPROFILE\Documents\PowerShell\Modules",
        "$env:USERPROFILE\Documents\PowerShell\Modules\Core",
        "$env:USERPROFILE\Documents\PowerShell\Modules\Tools",
        "$env:USERPROFILE\Documents\PowerShell\Modules\UI",
        "$env:USERPROFILE\Documents\PowerShell\Modules\System",
        "$env:USERPROFILE\Documents\PowerShell\Scripts"
    )
    
    $missingPaths = @()
    
    foreach ($path in $expectedPaths) {
        if (Test-Path $path) {
            if (-not $SummaryOnly) {
                Write-Host "  ✓ $path" -ForegroundColor DarkGray
            }
        }
        else {
            $missingPaths += $path
            if (-not $SummaryOnly) {
                Write-Host "  ✗ $path" -ForegroundColor Red
            }
        }
    }
    
    $results.Structure = @{
        Status = ($missingPaths.Count -eq 0)
        MissingPaths = $missingPaths
    }
}

# Check profile loading
function Test-ProfileLoading {
    Write-Host "`n⚡ Profile Loading Verification:" -ForegroundColor Yellow
    
    try {
        # Try to load the profile
        . $PROFILE -ErrorAction Stop
        $results.Profile = @{Status = $true; Message = "Loaded successfully"}
        
        if (-not $SummaryOnly) {
            Write-Host "  ✓ Profile loads without errors" -ForegroundColor Green
        }
    }
    catch {
        $results.Profile = @{Status = $false; Message = "Error: $_"}
        
        if (-not $SummaryOnly) {
            Write-Host "  ✗ Profile error: $_" -ForegroundColor Red
        }
    }
}

# Display summary
function Show-Summary {
    Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
    Write-Host "📊 VERIFICATION SUMMARY" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    
    # Tools summary
    $toolsInstalled = ($results.Tools | Where-Object { $_.Status }).Count
    $toolsTotal = $results.Tools.Count
    $toolsColor = if ($toolsInstalled -eq $toolsTotal) { "Green" } elseif ($toolsInstalled -gt $toolsTotal/2) { "Yellow" } else { "Red" }
    Write-Host "Tools: $toolsInstalled/$toolsTotal installed" -ForegroundColor $toolsColor
    
    # Modules summary
    $modulesInstalled = ($results.Modules | Where-Object { $_.Status }).Count
    $modulesTotal = $results.Modules.Count
    $modulesColor = if ($modulesInstalled -eq $modulesTotal) { "Green" } elseif ($modulesInstalled -gt $modulesTotal/2) { "Yellow" } else { "Red" }
    Write-Host "Modules: $modulesInstalled/$modulesTotal installed" -ForegroundColor $modulesColor
    
    # Fonts summary
    $fontsInstalled = ($results.Fonts | Where-Object { $_.Status }).Count
    $fontsTotal = $results.Fonts.Count
    $fontsColor = if ($fontsInstalled -eq $fontsTotal) { "Green" } else { "Red" }
    Write-Host "Fonts: $fontsInstalled/$fontsTotal installed" -ForegroundColor $fontsColor
    
    # Profile status
    $profileColor = if ($results.Profile.Status) { "Green" } else { "Red" }
    Write-Host "Profile: $(if($results.Profile.Status){'✓ Loads'} else {'✗ Error'})" -ForegroundColor $profileColor
    
    # Structure status
    $structureColor = if ($results.Structure.Status) { "Green" } else { "Red" }
    Write-Host "Structure: $(if($results.Structure.Status){'✓ Complete'} else {'✗ Incomplete'})" -ForegroundColor $structureColor
    
    # Overall status
    $overall = ($toolsInstalled -eq $toolsTotal) -and 
               ($modulesInstalled -eq $modulesTotal) -and 
               ($fontsInstalled -eq $fontsTotal) -and 
               $results.Profile.Status -and 
               $results.Structure.Status
    
    Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
    if ($overall) {
        Write-Host "✅ ENVIRONMENT READY!" -ForegroundColor Green
        Write-Host "All components installed successfully." -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  ENVIRONMENT INCOMPLETE" -ForegroundColor Yellow
        
        # Show missing components
        $missingTools = $results.Tools | Where-Object { -not $_.Status } | ForEach-Object { $_.Name }
        $missingModules = $results.Modules | Where-Object { -not $_.Status } | ForEach-Object { $_.Name }
        $missingFonts = $results.Fonts | Where-Object { -not $_.Status } | ForEach-Object { $_.Name }
        
        if ($missingTools) {
            Write-Host "`nMissing tools:" -ForegroundColor Yellow
            foreach ($tool in $missingTools) {
                $fixInfo = $results.Tools | Where-Object { $_.Name -eq $tool -and $_.Fixable }
                if ($fixInfo) {
                    Write-Host "  - $tool (Run with -Fix to install)" -ForegroundColor White
                }
                else {
                    Write-Host "  - $tool" -ForegroundColor White
                }
            }
        }
        
        if ($missingModules) {
            Write-Host "`nMissing modules:" -ForegroundColor Yellow
            Write-Host "  Run with -Fix to install missing modules" -ForegroundColor White
        }
        
        if ($missingFonts) {
            Write-Host "`nMissing fonts:" -ForegroundColor Yellow
            Write-Host "  Re-run setup.ps1 or install manually" -ForegroundColor White
        }
        
        if (-not $results.Profile.Status) {
            Write-Host "`nProfile error:" -ForegroundColor Yellow
            Write-Host "  $($results.Profile.Message)" -ForegroundColor White
        }
        
        if (-not $results.Structure.Status -and $results.Structure.MissingPaths) {
            Write-Host "`nMissing directories:" -ForegroundColor Yellow
            foreach ($path in $results.Structure.MissingPaths) {
                Write-Host "  - $path" -ForegroundColor White
            }
        }
        
        Write-Host "`nRecommended actions:" -ForegroundColor Cyan
        Write-Host "  1. Run: .\verify-installation.ps1 -Fix (as admin)" -ForegroundColor White
        Write-Host "  2. Or re-run: .\setup.ps1" -ForegroundColor White
        Write-Host "  3. Check README.md troubleshooting section" -ForegroundColor White
    }
    
    Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
}

# Main execution
try {
    if ($Fix -and -not (Test-Admin)) {
        Write-Host "⚠️  Admin rights required for automatic fixes." -ForegroundColor Yellow
        Write-Host "   Run PowerShell as Administrator or use: gsudo powershell" -ForegroundColor White
    }
    
    Test-CoreTools
    Test-PowerShellModules
    Test-FontInstallation
    Test-ProjectStructure
    Test-ProfileLoading
    Show-Summary
    
    # Return exit code based on overall status
    $toolsInstalled = ($results.Tools | Where-Object { $_.Status }).Count
    $modulesInstalled = ($results.Modules | Where-Object { $_.Status }).Count
    $fontsInstalled = ($results.Fonts | Where-Object { $_.Status }).Count
    
    $overall = ($toolsInstalled -eq $results.Tools.Count) -and 
               ($modulesInstalled -eq $results.Modules.Count) -and 
               ($fontsInstalled -eq $results.Fonts.Count) -and 
               $results.Profile.Status -and 
               $results.Structure.Status
    
    exit $(if ($overall) { 0 } else { 1 })
}
catch {
    Write-Host "❌ Verification failed with error: $_" -ForegroundColor Red
    exit 1
}
