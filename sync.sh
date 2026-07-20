#!/bin/bash
#
# sync.sh — capture the current laptop's config into this repo and push.
#   - regenerates Brewfile from installed packages
#   - copies live home dotfiles into the repo (they are plain copies, not symlinks)
#   - stages tracked config + helper scripts, commits, and pushes
#
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

echo "Updating Brewfile..."
brew bundle dump --force --describe

echo "Pulling live dotfiles from home..."
cp "$HOME/.zshrc"     .zshrc     2>/dev/null || true
cp "$HOME/.gitconfig" .gitconfig 2>/dev/null || true
GHOSTTY="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
[ -f "$GHOSTTY" ] && cp "$GHOSTTY" ghostty/config

git add Brewfile .zshrc .gitconfig ghostty/config macos.sh scripts launchd

if git diff --staged --quiet; then
    echo "Nothing to commit, already up to date."
    exit 0
fi

COMMIT_MSG="sync: $(date '+%Y-%m-%d %H:%M')"
git commit -m "$COMMIT_MSG"
git push

echo "Done — pushed as: $COMMIT_MSG"
