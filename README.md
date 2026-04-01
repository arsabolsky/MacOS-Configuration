# 💻 MacOS-Configuration

A robust, automated environment setup for macOS. This repository captures my current system configuration—including apps, terminal settings, and system defaults—allowing for a seamless setup on any new Mac.

## 🚀 Quick Start (New Mac Setup)

To set up a fresh macOS environment, clone this repository and run the master setup script:

```bash
git clone https://github.com/your-username/MacOS-Configuration.git ~/Documents/MacOS-Configuration
cd ~/Documents/MacOS-Configuration
chmod +x setup.sh
./setup.sh
```

## 📦 What's Managed?

- **Package Management**: Automated installation of all CLI tools, GUI applications, and Mac App Store apps via **Homebrew** (`Brewfile`).
- **Shell Configuration**: Unified **ZSH** setup with **Oh My Zsh**, custom themes, and productivity aliases.
- **Git Settings**: Global Git configuration including user identity and GitHub CLI credential helpers.
- **Terminal Emulator**: Full configuration for **Ghostty**, including themes, fonts, and window behavior.
- **System Defaults**: Automated macOS system settings (Dock, Finder, Keyboard, Trackpad) via `macos.sh`.

## 📂 File Structure

| File | Description |
| :--- | :--- |
| `setup.sh` | The master installation script. Orchestrates the entire setup. |
| `Brewfile` | A complete list of all installed Homebrew formulae, casks, and Mac App Store apps. |
| `.zshrc` | My primary shell configuration (merged with my current Oh My Zsh setup). |
| `.gitconfig` | My global Git configuration and user settings. |
| `ghostty/config` | Configuration for the Ghostty terminal emulator. |
| `macos.sh` | A script to apply my specific macOS system defaults (Dock size, Finder settings, etc.). |
| `macos_defaults_backup.txt` | A complete snapshot of my current `defaults` database for reference. |

## 🛠️ Maintenance & Updating

### Update your Brewfile
If you install new software via Homebrew, update the repository's `Brewfile` with:
```bash
brew bundle dump --force --describe
```

### Refresh macOS Defaults Backup
To capture a fresh snapshot of your system settings:
```bash
defaults read > macos_defaults_backup.txt
```

### Apply Changes Manually
If you've modified a config file (like `.zshrc`) and want to apply it immediately without re-running the full setup:
```bash
source ~/.zshrc
```

---
*Created and maintained with 🪄 and Gemini CLI.*



https://github.com/mathiasbynens/dotfiles