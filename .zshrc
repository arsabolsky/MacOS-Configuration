# .zshrc - Unified ZSH Configuration (Oh My Zsh + Custom)
# -------------------------------------------------------------------
# Oh My Zsh Core Setup
# -------------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="gnzh"
plugins=(git)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# -------------------------------------------------------------------
# Path Exports & Homebrew
# -------------------------------------------------------------------

# Homebrew for Apple Silicon
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="$HOME/bin:/usr/local/bin:$PATH"

# -------------------------------------------------------------------
# New Utility Aliases
# -------------------------------------------------------------------

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"

# List files
alias ls="ls -G" 
alias ll="ls -lahG"
alias l="ls -lG"

# Git (High Frequency)
alias gs="git status"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# Gemini CLI
alias ask="gemini"

# Development
alias py="python3"
alias pip="pip3"
alias pn="pnpm"

# Utility
alias reload="source ~/.zshrc"
alias cls="clear"
alias path='echo -e ${PATH//:/\\n}' 
alias ip="curl ifconfig.me"         

# macOS Specific
alias showhidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidehidden="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# -------------------------------------------------------------------
# Your Custom User Aliases
# -------------------------------------------------------------------

alias sudo='sudo TERM=xterm-256color'
alias eyarc='cd ~/Documents/Work/EYARC-BYU-Webapp/'
alias 350='cd ~/Documents/BYU/Winter\ 2026/IT\&C\ 350/NMAP-Data-Correlation-Platform/'
alias 266='cd ~/Documents/BYU/Winter\ 2026/IT\&C\ 266/Cyber-266-Vulnerability-Walkthroughs/Overflow-Buffers/'

# -------------------------------------------------------------------
# History & Shell Behavior
# -------------------------------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups

zstyle ':omz:update' mode auto
ENABLE_CORRECTION="true"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/arsabolsky/.lmstudio/bin"
# End of LM Studio CLI section

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Added by Antigravity
export PATH="/Users/arsabolsky/.antigravity/antigravity/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"


# 1. Define settings first
export ZSH_AI_PROVIDER="ollama"
export ZSH_AI_OLLAMA_MODEL="qwen3.5:0.8b" # Double-check this name with 'ollama list'

# 2. Bypass the hardcoded Anthropic check
# export ANTHROPIC_API_KEY="dummy_key_to_silence_warning"

# 3. Load the plugin last
source $(brew --prefix)/share/zsh-ai/zsh-ai.plugin.zsh

autoload -Uz compinit
compinit

# Completion menu polish
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' group-name ''

# Inline suggestions from history (accept with →)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
