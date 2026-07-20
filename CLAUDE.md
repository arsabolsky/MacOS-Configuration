# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A dotfiles/config repo for automating macOS environment setup. The main entry point is `setup.sh`, which orchestrates everything from a fresh Mac. On a fresh install `setup.sh` symlinks configs into their home-directory locations; ongoing changes on an existing machine are captured back into the repo with `sync.sh` (which copies the live home dotfiles in and pushes).

## Key Commands

**Full setup (fresh Mac only):**
```bash
chmod +x setup.sh && ./setup.sh
```

**Apply macOS system defaults only:**
```bash
./macos.sh
```

**Update Brewfile after installing new software:**
```bash
brew bundle dump --force --describe
```

**Install/sync packages from Brewfile:**
```bash
brew bundle install
```

**Reload shell config after editing `.zshrc`:**
```bash
source ~/.zshrc
# or use the alias:
reload
```

**Capture a fresh snapshot of all macOS defaults:**
```bash
defaults read > macos_defaults_backup.txt
```

**Sync this laptop's current config back into the repo and push:**
```bash
./sync.sh   # regenerates Brewfile, copies live dotfiles in, commits, pushes
```

## Architecture

`setup.sh` is the orchestrator. It runs steps in order:
1. Installs Homebrew (if missing), then updates it
2. Installs Oh My Zsh (if missing)
3. Runs `brew bundle install` from `Brewfile`
4. Creates `~/Developer/Projects` and `~/Developer/Tools`
5. Symlinks `.zshrc`, `.gitconfig`, and `ghostty/config` into their home-directory locations
6. Runs `macos.sh` to apply system defaults

**Symlinking pattern:** All config files live in this repo and are symlinked out. Edits to files here take effect immediately (no re-running setup) for shell config (`source ~/.zshrc`), or on next app launch for others. Changes to `.gitconfig` and `ghostty/config` take effect immediately.

**`macos.sh`** applies `defaults write` commands affecting Finder, Dock, Activity Monitor, and Launch Services. It kills affected apps at the end to force them to reload settings. Many settings are commented out — they document available options without applying them.

**`Brewfile`** covers: CLI tools, GUI casks, Mac App Store apps (`mas`), and VS Code extensions. It uses three third-party taps (hashicorp, lihaoyun6, theboredteam/boring-notch).

## Shell Environment (`.zshrc`)

- Theme: `gnzh` via Oh My Zsh
- Notable aliases: `pn` → pnpm, `py` → python3, `ask` → gemini (Gemini CLI)
- Project shortcuts: `eyarc` and `350`, `266` jump to specific project directories

## Git Config (`.gitconfig`)

- Uses `gh auth git-credential` for both github.com and gist.github.com
- Default editor: VS Code (`code --wait`)
- Default branch: `main`
- Pull strategy: merge (not rebase)

## Helper Scripts (`scripts/`) and Schedules (`launchd/`)

Personal utilities, kept in the repo and installable on any Mac.

- `scripts/reset-juicy-trial.sh` — resets the Juicy app's local trial state (clears `trialStartDate` in UserDefaults + the `~/Library/Application Support/Juicy/.trial` mirror, while the app is quit). Flags: `--status`, `--relaunch`.
- `scripts/juicy-dev.sh` — forces Juicy trial states (`active`/`expired`/`unknown`/`<N days ago>`), expires Pro updates, or clears the RevenueCat purchase cache.
- `scripts/install-juicy-trialreset.sh` — copies the scripts to `~/bin` and installs a per-user LaunchAgent that runs the reset daily at 04:00. `--uninstall` removes it. Paths are derived from the current user, so it is portable.
- `launchd/io.sevendegrees.juicy.trialreset.plist` — reference copy of that LaunchAgent (managed via `launchctl bootstrap`/`bootout gui/$(id -u)/...`).
