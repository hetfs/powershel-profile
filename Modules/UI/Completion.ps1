# Completion.ps1 - Enhanced tab completion

# PSFzf integration for fuzzy finding
try {
    Import-Module PSFzf -ErrorAction Stop
    
    # Override Ctrl+T and Ctrl+R
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    
    Write-Host "  ✓ PSFzf fuzzy completion" -ForegroundColor DarkGray
}
catch {
    Write-Warning "PSFzf not available. Install with: Install-Module PSFzf"
}

# zoxide directory jumping
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& {
        $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
        (zoxide init --hook $hook powershell) -join "`n"
    })
    
    # Alias for zoxide
    Set-Alias z zi
}
