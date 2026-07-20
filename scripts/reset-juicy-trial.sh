#!/usr/bin/env bash
#
# reset-juicy-trial.sh — reset Juicy's free-trial state for testing.
#
# Juicy stores the trial start in TWO places and reads whichever exists:
#   1. UserDefaults key `trialStartDate`  (~/Library/Preferences/<bundle>.plist)
#   2. mirror file `.trial`               (~/Library/Application Support/Juicy/.trial)
# Both must be cleared, and the app must be QUIT first — while running it keeps
# an in-memory copy of its prefs and rewrites them on exit, clobbering the reset.
#
# Usage:
#   ./reset-juicy-trial.sh            # reset the trial
#   ./reset-juicy-trial.sh --status   # show current trial state, change nothing
#   ./reset-juicy-trial.sh --relaunch # reset, then reopen Juicy
#
set -euo pipefail

BUNDLE_ID="io.sevendegrees.juicy.direct"
APP_NAME="Juicy"
PREFS="$HOME/Library/Preferences/${BUNDLE_ID}.plist"
TRIAL_FILE="$HOME/Library/Application Support/Juicy/.trial"

DO_RELAUNCH=0
STATUS_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --relaunch) DO_RELAUNCH=1 ;;
    --status)   STATUS_ONLY=1 ;;
    -h|--help)  grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

show_state() {
  local ud tf
  ud="$(defaults read "$BUNDLE_ID" trialStartDate 2>/dev/null || echo '(none)')"
  if [[ -f "$TRIAL_FILE" ]]; then tf="$(cat "$TRIAL_FILE")"; else tf='(none)'; fi
  echo "  UserDefaults trialStartDate : $ud"
  echo "  .trial file                 : $tf"
}

echo "== Juicy trial state (before) =="
show_state

if [[ "$STATUS_ONLY" == "1" ]]; then
  exit 0
fi

# 1. Quit the app so it doesn't rewrite prefs on exit.
if pgrep -xq "$APP_NAME"; then
  echo "== Quitting $APP_NAME =="
  osascript -e "quit app \"$APP_NAME\"" 2>/dev/null || true
  for _ in $(seq 1 20); do
    pgrep -xq "$APP_NAME" || break
    sleep 0.25
  done
  if pgrep -xq "$APP_NAME"; then
    echo "!! $APP_NAME is still running — quit it manually and re-run." >&2
    exit 1
  fi
fi

# 2. Clear the UserDefaults key (through cfprefsd, the supported path).
echo "== Clearing UserDefaults key =="
defaults delete "$BUNDLE_ID" trialStartDate 2>/dev/null || echo "  (key was not set)"

# 3. Remove the mirror file.
echo "== Removing .trial file =="
rm -f "$TRIAL_FILE" && echo "  removed $TRIAL_FILE" || true

# 4. Flush cfprefsd so the next launch reads fresh values.
killall cfprefsd 2>/dev/null || true

echo "== Juicy trial state (after) =="
show_state

# 5. Optionally relaunch.
if [[ "$DO_RELAUNCH" == "1" ]]; then
  echo "== Relaunching $APP_NAME =="
  open -a "$APP_NAME"
fi

echo "Done. Trial reset to UNKNOWN — next launch starts a fresh 3-day trial."
