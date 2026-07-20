#!/usr/bin/env bash
#
# install-juicy-trialreset.sh — install the Juicy trial-reset scripts to ~/bin
# and schedule a daily reset via a launchd LaunchAgent.
#
# Portable: derives paths from the current user, so it works on any Mac.
# Idempotent: safe to re-run (reloads the agent).
#
# Usage:
#   ./install-juicy-trialreset.sh            # install + schedule (04:00 daily)
#   ./install-juicy-trialreset.sh --uninstall
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LABEL="io.sevendegrees.juicy.trialreset"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
BIN_DIR="$HOME/bin"
LOG="$HOME/Library/Logs/juicy-trialreset.log"

if [[ "${1:-}" == "--uninstall" ]]; then
  launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
  rm -f "$PLIST"
  echo "Uninstalled ${LABEL} (scripts left in ${BIN_DIR})."
  exit 0
fi

echo "Installing Juicy trial-reset scripts to ${BIN_DIR}..."
mkdir -p "$BIN_DIR"
cp "$REPO_DIR/scripts/reset-juicy-trial.sh" "$BIN_DIR/"
cp "$REPO_DIR/scripts/juicy-dev.sh"        "$BIN_DIR/"
chmod +x "$BIN_DIR/reset-juicy-trial.sh" "$BIN_DIR/juicy-dev.sh"

echo "Writing LaunchAgent (daily at 04:00) to ${PLIST}..."
mkdir -p "$(dirname "$PLIST")" "$(dirname "$LOG")"
cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${BIN_DIR}/reset-juicy-trial.sh</string>
        <string>--relaunch</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key><integer>4</integer>
        <key>Minute</key><integer>0</integer>
    </dict>
    <key>RunAtLoad</key><false/>
    <key>StandardOutPath</key><string>${LOG}</string>
    <key>StandardErrorPath</key><string>${LOG}</string>
</dict>
</plist>
PLISTEOF

plutil -lint "$PLIST" >/dev/null
launchctl bootout   "gui/$(id -u)/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "Loaded. Verify: launchctl print gui/\$(id -u)/${LABEL}"
echo "Test now:      launchctl kickstart -p gui/\$(id -u)/${LABEL}"
echo "Log:           ${LOG}"
