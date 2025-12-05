# Core functions and aliases

# Navigation shortcuts
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function home { Set-Location $HOME }

# Aliases
Set-Alias ll Get-ChildItem
Set-Alias grep findstr
Set-Alias which Get-Command
Set-Alias cat Get-Content

# Quick edit functions
function Edit-Profile { code $PROFILE }
function Reload-Profile { . $PROFILE }

Write-Host "  Core module loaded" -ForegroundColor DarkGray
