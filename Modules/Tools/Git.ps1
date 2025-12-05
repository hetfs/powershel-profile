# Git.ps1 - Git integration and aliases

# Enhanced git aliases
function g { git @args }
function gs { git status }
function ga { git add @args }
function gc { git commit -v @args }
function gp { git push @args }
function gl { git log --oneline --graph --all -20 }
function gd { git diff @args }

# Git worktree helper
function gwt {
    param([string]$branch)
    $worktreePath = "../$branch"
    git worktree add $worktreePath $branch
    Set-Location $worktreePath
}

# GitHub CLI aliases
if (Get-Command gh -ErrorAction SilentlyContinue) {
    function ghpr { gh pr create --fill }
    function ghissue { gh issue create }
}
