#!/bin/bash

# setup.sh - MacOS Environment Setup Script
# Author: Gemini CLI

set -e # Exit immediately if a command fails

echo "🚀 Starting MacOS Setup..."

# 1. Install Homebrew (if not already installed)
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH (standard on Apple Silicon Macs)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed, updating..."
    brew update
fi

# 2. Install Oh My Zsh (if not already installed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed, skipping..."
fi

# 3. Install dependencies from Brewfile
if [[ -f Brewfile ]]; then
    echo "Installing Brewfile dependencies..."
    brew bundle install
else
    echo "Brewfile not found, skipping..."
fi

# 3. Create common directories
echo "Creating development directories..."
mkdir -p ~/Developer/Projects
mkdir -p ~/Developer/Tools

# 4. Symlink configuration files
echo "Symlinking configuration files..."
ln -sf "$(pwd)/.zshrc" "$HOME/.zshrc"
ln -sf "$(pwd)/.gitconfig" "$HOME/.gitconfig"

mkdir -p "$HOME/.config/ghostty"
ln -sf "$(pwd)/ghostty/config" "$HOME/.config/ghostty/config"

# 5. Authenticate GitHub CLI (.gitconfig uses `gh auth git-credential`)
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        echo "GitHub CLI already authenticated, skipping."
    else
        echo "Authenticating GitHub CLI (needed for git push + credential helper)..."
        gh auth login || echo "⚠️  gh auth login skipped/failed — run 'gh auth login' later."
    fi
else
    echo "⚠️  gh not found (expected from Brewfile) — install it, then run 'gh auth login'."
fi

# 6. Optionally install the daily Juicy trial-reset scheduler
if [[ -x scripts/install-juicy-trialreset.sh ]]; then
    read -r -p "Install the daily Juicy trial-reset LaunchAgent? [y/N] " reply || reply=""
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        ./scripts/install-juicy-trialreset.sh || echo "⚠️  Juicy scheduler install failed."
    else
        echo "Skipped Juicy scheduler (run scripts/install-juicy-trialreset.sh anytime)."
    fi
fi

# 7. Set macOS defaults
echo "Setting macOS defaults..."
chmod +x macos.sh
./macos.sh

# 8. Final instructions
echo "✅ Setup complete!"
echo "Next steps:"
echo "1. Restart your terminal (or run: source ~/.zshrc)."
echo "2. If any 'mas' apps failed, sign into the Mac App Store and re-run: brew bundle install."
echo "3. Verify GitHub auth with: gh auth status"
