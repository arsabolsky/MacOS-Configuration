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

# 5. Set macOS defaults
echo "Setting macOS defaults..."
chmod +x macos.sh
./macos.sh

# 6. Final instructions
echo "✅ Setup complete!"
echo "Next steps:"
echo "1. Restart your terminal."
echo "2. Log into the Mac App Store (if you added 'mas' apps)."
echo "3. Configure your shell profile (e.g., ~/.zshrc) to use the new tools."
