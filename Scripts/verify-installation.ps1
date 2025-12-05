# Scripts/verify-installation.ps1
# Post-installation verification script

param(
    [switch]$Fix,
    [switch]$SummaryOnly
)

Write-Host "🔍 PowerShell Environment Verification" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

# Configuration
$requiredTools = @(
    @{Name = "git"; Display = "Git"; InstallCommand = "winget install Git.Git --silent"},
    @{Name = "starship"; Display = "Starship"; InstallCommand = "winget install starship.starship --silent"},
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

# Results tracking
$results = @{
    Tools = @()
    Modules = @()
    Fonts = $null
    Profile = $null
    Structure = $null
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-CoreTools {
    Write-Host "`n📦 Core Tools:" -ForegroundColor Yellow
    
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
            $message = "Not found"
        }
        
        $results.Tools += @{Name = $tool.Display; Status = $status; Message = $message}
        
        if (-not $SummaryOnly) {
            $color = if ($status) { "Green" } else { "Red" }
            $symbol = if ($status) { "✓" } else { "✗" }
            Write-Host "  $symbol $($tool.Display): $message" -ForegroundColor $color
        }
    }
}

function Test-PowerShellModules {
    Write-Host "`n🔌 PowerShell Modules:" -ForegroundColor Yellow
    
    foreach ($module in $requiredModules) {
        $status = $false
        $message = ""
        
        try {
            $moduleInfo = Get-Module -Name $module.Name -ListAvailable -ErrorAction Stop | Select-Object -First 1
            if ($moduleInfo) {
                $status = $true
                $message = "v$($moduleInfo.Version)"
            }
        }
        catch {
            $message = "Not installed"
        }
        
        $results.Modules += @{Name = $module.Display; Status = $status; Message = $message}
        
        if (-not $SummaryOnly) {
            $color = if ($status) { "Green" } else { "Red" }
            $symbol = if ($status) { "✓" } else { "✗" }
            Write-Host "  $symbol $($module.Display): $message" -ForegroundColor $color
        }
    }
}

function Test-FontInstallation {
    Write-Host "`n🔤 Fonts:" -ForegroundColor Yellow
    
    $status = $false
    $message = ""
    
    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        
        if ($fontFamilies -contains "CaskaydiaCove NF") {
            $status = $true
            $message = "Installed"
        } else {
            $message = "Not found"
        }
    }
    catch {
        $message = "Check failed"
    }
    
    $results.Fonts = @{Status = $status; Message = $message}
    
    if (-not $SummaryOnly) {
        $color = if ($status) { "Green" } else { "Red" }
        $symbol = if ($status) { "✓" } else { "✗" }
        Write-Host "  $symbol CaskaydiaCove NF: $message" -ForegroundColor $color
    }
}

function Test-ProjectStructure {
    Write-Host "`n📁 Project Structure:" -ForegroundColor Yellow
    
    $expectedPaths = @(
        "$env:USERPROFILE\Documents\PowerShell\Modules\Core",
        "$env:USERPROFILE\Documents\PowerShell\Modules\Tools",
        "$env:USERPROFILE\Documents\PowerShell\Modules\UI",
        "$env:USERPROFILE\Documents\PowerShell\Modules\System",
        "$env:USERPROFILE\Documents\PowerShell\Scripts"
    )
    
    $missingPaths = @()
    $existingPaths = @()
    
    foreach ($path in $expectedPaths) {
        if (Test-Path $path) {
            $existingPaths += $path
            if (-not $SummaryOnly) {
                Write-Host "  ✓ $path" -ForegroundColor Green
            }
        }
        else {
            $missingPaths += $path
            if (-not $SummaryOnly) {
                Write-Host "  ✗ $path" -ForegroundColor Red
            }
            # Auto-create if -Fix is specified
            if ($Fix) {
                try {
                    New-Item -ItemType Directory -Path $path -Force | Out-Null
                    Write-Host "    Created: $path" -ForegroundColor Green
                    $missingPaths = $missingPaths | Where-Object { $_ -ne $path }
                    $existingPaths += $path
                }
                catch {
                    Write-Host "    Failed to create: $path" -ForegroundColor Red
                }
            }
        }
    }
    
    $results.Structure = @{
        Status = ($missingPaths.Count -eq 0)
        Existing = $existingPaths.Count
        Total = $expectedPaths.Count
        MissingPaths = $missingPaths
    }
}

function Test-ProfileLoading {
    Write-Host "`n⚡ Profile:" -ForegroundColor Yellow
    
    try {
        . $PROFILE -ErrorAction Stop
        $results.Profile = @{Status = $true; Message = "Loads successfully"}
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

function Show-Summary {
    Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
    Write-Host "📊 VERIFICATION SUMMARY" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    
    # Tools
    $toolsInstalled = ($results.Tools | Where-Object { $_.Status }).Count
    $toolsTotal = $results.Tools.Count
    $toolsColor = if ($toolsInstalled -eq $toolsTotal) { "Green" } elseif ($toolsInstalled -gt $toolsTotal/2) { "Yellow" } else { "Red" }
    Write-Host "Tools: $toolsInstalled/$toolsTotal" -ForegroundColor $toolsColor
    
    # Modules
    $modulesInstalled = ($results.Modules | Where-Object { $_.Status }).Count
    $modulesTotal = $results.Modules.Count
    $modulesColor = if ($modulesInstalled -eq $modulesTotal) { "Green" } else { "Red" }
    Write-Host "Modules: $modulesInstalled/$modulesTotal" -ForegroundColor $modulesColor
    
    # Fonts
    $fontsColor = if ($results.Fonts.Status) { "Green" } else { "Red" }
    $fontSymbol = if ($results.Fonts.Status) { "✓" } else { "✗" }
    Write-Host "Font: $fontSymbol $($results.Fonts.Message)" -ForegroundColor $fontsColor
    
    # Profile
    $profileColor = if ($results.Profile.Status) { "Green" } else { "Red" }
    Write-Host "Profile: $(if($results.Profile.Status){'✓ Loads'} else {'✗ Error'})" -ForegroundColor $profileColor
    
    # Structure
    $structureColor = if ($results.Structure.Status) { "Green" } else { "Red" }
    Write-Host "Structure: $($results.Structure.Existing)/$($results.Structure.Total) directories" -ForegroundColor $structureColor
    
    # Overall
    $overall = $toolsInstalled -eq $toolsTotal -and 
               $modulesInstalled -eq $modulesTotal -and 
               $results.Fonts.Status -and 
               $results.Profile.Status -and 
               $results.Structure.Status
    
    Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
    
    if ($overall) {
        Write-Host "✅ ENVIRONMENT READY!" -ForegroundColor Green
        Write-Host "All components installed successfully." -ForegroundColor Green
    } else {
        Write-Host "⚠️  ENVIRONMENT INCOMPLETE" -ForegroundColor Yellow
        
        # Missing tools
        $missingTools = $results.Tools | Where-Object { -not $_.Status } | ForEach-Object { $_.Name }
        if ($missingTools) {
            Write-Host "`nMissing tools:" -ForegroundColor Yellow
            foreach ($tool in $missingTools) {
                Write-Host "  - $tool" -ForegroundColor White
            }
            Write-Host "  Run with -Fix to install missing tools (requires admin)" -ForegroundColor Gray
        }
        
        # Missing modules
        $missingModules = $results.Modules | Where-Object { -not $_.Status } | ForEach-Object { $_.Name }
        if ($missingModules) {
            Write-Host "`nMissing modules:" -ForegroundColor Yellow
            foreach ($module in $missingModules) {
                Write-Host "  - $module" -ForegroundColor White
            }
            Write-Host "  Run with -Fix to install missing modules" -ForegroundColor Gray
        }
        
        # Missing directories
        if ($results.Structure.MissingPaths) {
            Write-Host "`nMissing directories:" -ForegroundColor Yellow
            foreach ($path in $results.Structure.MissingPaths) {
                Write-Host "  - $path" -ForegroundColor White
            }
            Write-Host "  Run with -Fix to create missing directories" -ForegroundColor Gray
        }
        
        Write-Host "`n🔧 Recommended actions:" -ForegroundColor Cyan
        if ($Fix) {
            Write-Host "  Run: .\setup.ps1" -ForegroundColor White
        } else {
            Write-Host "  Run: .\verify-installation.ps1 -Fix" -ForegroundColor White
        }
        Write-Host "  Check README.md for troubleshooting" -ForegroundColor White
    }
    
    Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
}

# Main execution
try {
    Test-CoreTools
    Test-PowerShellModules
    Test-FontInstallation
    Test-ProjectStructure
    Test-ProfileLoading
    Show-Summary
}
catch {
    Write-Host "❌ Verification failed: $_" -ForegroundColor Red
}
