# 🚀 PowerShell Profile Modular Edition

A structured and developer-friendly PowerShell profile that uses a modular design to stay clean, fast, and easy to maintain. It works well for developers, system administrators, and power users who want a predictable and customizable shell experience.

## ✨ Features

* **Modular Structure** Logical modules keep the profile clean and manageable
* **Auto-Updating**  Built-in update checks for the profile and PowerShell
* **Enhanced UX** Helpful prompts, smart completions, and practical defaults
* **Cross-Platform** Works on Windows PowerShell and PowerShell 7+
* **Git-Friendly** Easy to sync and version control
* **Developer Focused** Git shortcuts, dev tools, and productivity tweaks
* **Comprehensive Verification** Built-in installation verification with auto-fix capabilities

---

## 📦 Quick Start

### Prerequisites

* Windows PowerShell 5.1+ or PowerShell 7+
* Admin rights for some optional tools
* Git (optional but recommended)

### For New Users

1. **Clone the repository anywhere you prefer**

```powershell
git clone https://github.com/hetfs/powershell-profile.git
```

2. **Run the setup script from the project root**

```powershell
# Navigate to your project folder
Set-Location "$HOME\Documents\PowerShell"

# Execute your local installer
.\setup.ps1
```

3. **Reload your profile**

```powershell
. $PROFILE
```

### 🔄 For Users Migrating from Previous Setup

If you're upgrading from an older version or different PowerShell setup:

1. **Backup Your Current Setup**

```powershell
# Backup current profile
Copy-Item $PROFILE "$PROFILE.backup_$(Get-Date -Format 'yyyyMMdd')"

# Backup old modules if any
if (Test-Path "$HOME\Documents\WindowsPowerShell\Modules") {
    Copy-Item "$HOME\Documents\WindowsPowerShell\Modules" "$HOME\Documents\WindowsPowerShell\Modules.backup" -Recurse
}
```

2. **Run the New Modular Setup**

```powershell
# Navigate to your project directory
Set-Location "$HOME\Documents\PowerShell"

# Run the new modular setup
.\setup.ps1
```

3. **Verify Installation**

```powershell
# Test core components
Get-Command git, starship, zoxide, rg, bat

# Test PowerShell modules
Get-Module posh-git, Terminal-Icons, PSReadLine, PSFzf

# Check profile loading
. $PROFILE
```

### Alternative One-Line Install (Windows)

```powershell
irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/setup.ps1 | iex
```

---

## 📁 Project Structure

```
Documents/PowerShell/
├── setup.ps1                                # Main installer (project root)
├── Microsoft.PowerShell_profile.ps1         # Main profile entry point
├── Modules/                                 # All modular components
│   ├── Core/                                # Essential functionality
│   │   ├── Configuration.ps1                # Settings and environment
│   │   ├── Functions.ps1                    # Core functions
│   │   ├── Utilities.ps1                    # Helper utilities
│   │   └── Aliases.ps1                      # Command shortcuts
│   ├── Tools/                               # Development tools
│   │   ├── Git.ps1                          # Git integration
│   │   ├── PackageManager.ps1               # Winget and package manager tools
│   │   └── Development.ps1                  # Development environment helpers
│   ├── UI/                                  # User interface
│   │   ├── Terminal.ps1                     # Terminal setup
│   │   ├── Completion.ps1                   # Auto-completion
│   │   ├── Theme.ps1                        # Themes and colors
│   │   └── Prompt.ps1                       # Custom prompt
│   ├── System/                              # System utilities
│   │   ├── Network.ps1                      # Networking tools
│   │   ├── Processes.ps1                    # Process management
│   │   └── Updates.ps1                      # Update functions
│   └── Private/                             # Sensitive data (ignored by Git)
│       └── Secrets.ps1                      # API keys and tokens
├── Scripts/                                 # Helper scripts and utilities
│   └── verify-installation.ps1              # Post-install verification and auto-fix
└── README.md                                # Documentation
```

**Note**: The installer moves everything into the correct `$HOME\Documents\PowerShell` structure automatically.

---

## ✅ Verification & Troubleshooting

### Comprehensive Verification Script

After installation, you can run a detailed verification check:

```powershell
# Basic verification (shows all checks)
.\Scripts\verify-installation.ps1

# Fix missing components automatically (requires admin)
.\Scripts\verify-installation.ps1 -Fix

# Show only summary without detailed output
.\Scripts\verify-installation.ps1 -SummaryOnly

# Combine fix with summary
.\Scripts\verify-installation.ps1 -Fix -SummaryOnly
```

### What the Verification Script Checks

| Check Category | Components Verified | Auto-Fix Available |
|----------------|---------------------|-------------------|
| **Core Tools** | git, starship, zoxide, rg, bat, fd, eza, delta, gsudo, gh, lazygit, neovim, tldr | ✅ Yes |
| **PowerShell Modules** | posh-git, Terminal-Icons, PSReadLine, PSFzf | ✅ Yes |
| **Fonts** | CaskaydiaCove NF (Nerd Font) | ❌ Manual only |
| **Project Structure** | All required directories | ✅ Auto-creates |
| **Profile Loading** | Profile execution without errors | ❌ Manual fix |

### Quick Manual Verification

If you prefer to check manually:

```powershell
# Test core tools
Get-Command git, starship, zoxide, rg, bat, fd, eza

# Test PowerShell modules
Get-Module posh-git, Terminal-Icons, PSReadLine, PSFzf -ListAvailable

# Test profile loading
. $PROFILE
```

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Profile not loading | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Missing modules | Run `.\setup.ps1` again or use `.\Scripts\verify-installation.ps1 -Fix` |
| Font not appearing | Restart Windows Terminal and set font to "CaskaydiaCove NF" |
| Starship not showing | Ensure `starship init powershell` is in your prompt configuration |
| Admin rights needed for fixes | Run PowerShell as Administrator or use `gsudo powershell` |

### Exit Codes

The verification script returns:
- **Exit Code 0**: All components verified successfully
- **Exit Code 1**: One or more components missing or errors found

---

## 🛠️ Customization

### Override System

Add a `profile.ps1` file inside your PowerShell directory to override settings, shortcuts, or functions.

```powershell
# $HOME\Documents\PowerShell\profile.ps1

$debug_Override = $true
$EDITOR_Override = "code"

function Update-Profile_Override {
    Write-Host "Custom update routine"
}

function My-CustomFunction {
    Write-Host "Custom logic active"
}
```

### Available Overrides

| Variable | Description | Default |
| --- | --- | --- |
| `$debug_Override` | Enable debug mode | `$false` |
| `$EDITOR_Override` | Preferred editor | Auto-detected |
| `$repo_root_Override` | Update source repo | hetfs |
| `$updateInterval_Override` | Update frequency (days) | 7   |

| Function | Description |
| --- | --- |
| `Debug-Message_Override` | Custom debug message |
| `Update-Profile_Override` | Custom update logic |
| `Update-PowerShell_Override` | Custom PowerShell update |
| `Clear-Cache_Override` | Custom cache clearing |
| `Get-Theme_Override` | Custom theme setup |

---

## 📦 Creating Your Own Modules

1. Add a `.ps1` file inside `Modules/<category>/`
2. Define your functions and aliases
3. The main profile loads it automatically

Example: `Modules/Tools/Custom.ps1`

```powershell
function Start-Dev {
    code .
    Start-Process "http://localhost:3000"
}
```

---

## 🔧 Key Commands

### Profile Management

| Command | Description |
| --- | --- |
| `Update-Profile` | Update profile files |
| `Update-PowerShell` | Update PowerShell |
| `Edit-Profile` | Edit main profile |
| `ep` | Alias for Edit-Profile |
| `reload-profile` | Reload profile |

### Git Shortcuts

| Shortcut | Command |
| --- | --- |
| `gs` | `git status` |
| `ga` | `git add .` |
| `gc "msg"` | `git commit -m "msg"` |
| `gpush` | `git push` |
| `gpull` | `git pull` |
| `gcom "msg"` | Add, commit, push |

### System Utilities

| Shortcut | Description |
| --- | --- |
| `admin` | Open admin terminal |
| `uptime` | System uptime |
| `sysinfo` | System information |
| `flushdns` | Clear DNS cache |
| `Get-PubIP` | Public IP address |
| `Clear-Cache` | Clear profile cache |

### File Operations

| Shortcut | Description |
| --- | --- |
| `touch file.txt` | Create file |
| `mkcd dir` | Create and enter dir |
| `trash file` | Move to Recycle Bin |
| `ff pattern` | Search files |
| `unzip file.zip` | Extract zip |

### Navigation

| Shortcut | Description |
| --- | --- |
| `docs` | Documents folder |
| `dtop` | Desktop folder |
| `la` | List all files |
| `ll` | Detailed list |
| `z` | Smart jumping via zoxide |

### Development

| Shortcut | Description |
| --- | --- |
| `winutil` | System utility |
| `winutildev` | Dev version |
| `hb file.txt` | Upload to Hastebin |
| `e` | Enhanced directory listing |

---

## 🤝 Contributing

### Getting Started

1. Fork the repo
2. Create a feature branch
3. Add or change modules
4. Test using `. $PROFILE`
5. Commit and push
6. Open a Pull Request

### Guidelines

* Keep changes modular
* Add help text where useful
* Avoid breaking existing features
* Test on Windows PowerShell and PowerShell 7
* Never commit secrets

---

## 🐛 Debugging

### Enable Debug Mode

```powershell
$debug_Override = $true
```

### Common Issues

* Profile not loading → `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
* Missing modules → Install required dependencies
* Duplicate function names → Check overrides and module paths

### Testing

```powershell
. $PROFILE
Update-Profile
$Error[0] | Format-List -Force
```

---

## 📚 Learning Resources

* [https://learn.microsoft.com/powershell/](https://learn.microsoft.com/powershell/)
* [https://www.powershellgallery.com/](https://www.powershellgallery.com/)
* [https://www.manning.com/books/learn-powershell-in-a-month-of-lunches](https://www.manning.com/books/learn-powershell-in-a-month-of-lunches)
* [https://powershell.org/](https://powershell.org/)

---

## 🔄 Updates

Weekly auto-checks run in the background.
Run manual updates with:

```powershell
Update-Profile
Update-PowerShell
```

Force an immediate check:

```powershell
$updateInterval = -1
Update-Profile
```

---

## ⚖️ License

MIT License maintained by hetfs

---

## 🙏 Acknowledgments

* [https://christitus.com/](https://christitus.com/)
* [https://github.com/devblackops/Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
* [https://github.com/PowerShell/PSReadLine](https://github.com/PowerShell/PSReadLine)

---

## 🆘 Support

* Issues — [https://github.com/hetfs/powershell-profile/issues](https://github.com/hetfs/powershell-profile/issues)
* Discussions — [https://github.com/hetfs/powershell-profile/discussions](https://github.com/hetfs/powershell-profile/discussions)

---

**Happy PowerShelling!** 🎉
