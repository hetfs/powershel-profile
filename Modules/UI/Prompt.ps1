# Prompt.ps1 - Starship prompt configuration

# Initialize Starship prompt[citation:9]
if (Get-Command starship -ErrorAction SilentlyContinue) {
    # Set Starship config location
    $env:STARSHIP_CONFIG = Join-Path (Split-Path $PROFILE -Parent) "starship.toml"
    
    # Initialize Starship
    Invoke-Expression (&starship init powershell)
}
else {
    Write-Warning "Starship not found. Using default prompt."
    Write-Host "Install with: winget install starship.starship" -ForegroundColor Yellow
    
    # Fallback prompt
    function prompt {
        $path = (Get-Location).Path.Replace($HOME, "~")
        "PS $path> "
    }
}
# Initialize Starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
# Initialize Starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
# Initialize Starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
# Initialize Starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
