# Development tools and Git functions

# Git shortcuts
function gs { git status }
function ga { git add . }
function gc { param([string]$Message) git commit -m $Message }
function gpush { git push }
function gpull { git pull }
function gco { param([string]$Branch) git checkout $Branch }

# Development helpers
function codehere { code . }
function openhere { explorer . }

Write-Host "  Tools module loaded" -ForegroundColor DarkGray
