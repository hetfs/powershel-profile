# Aliases.ps1 - Command shortcuts and Linux-like aliases

# Linux-like aliases[citation:10]
Set-Alias ll Get-ChildItem
Set-Alias grep findstr
Set-Alias cat Get-Content
Set-Alias which Get-Command
Set-Alias touch New-Item

# Custom function aliases
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function su { Start-Process wt -Verb runAs }  # Open elevated terminal[citation:10]

# Tool-specific aliases
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza --icons --git }
    function la { eza --icons --git -a }
    function ll { eza --icons --git -l }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias cat bat
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep { rg }
}
