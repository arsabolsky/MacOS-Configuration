#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

echo "Updating Brewfile..."
brew bundle dump --force --describe

if git diff --quiet && git diff --staged --quiet; then
    echo "Nothing changed, already up to date."
    exit 0
fi

git add Brewfile .zshrc .gitconfig ghostty/config macos.sh

if git diff --staged --quiet; then
    echo "Nothing to commit."
    exit 0
fi

COMMIT_MSG="sync: $(date '+%Y-%m-%d %H:%M')"
git commit -m "$COMMIT_MSG"
git push

echo "Done — pushed as: $COMMIT_MSG"
