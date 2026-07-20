#!/usr/bin/env bash
#
# juicy-dev.sh — drive Juicy's developer/testing features WITHOUT the menu,
# by writing the underlying state directly. Juicy must be QUIT while we write
# (it holds prefs in memory and rewrites them on exit), so every mutating
# command quits the app first and can optionally relaunch with --relaunch.
#
# Reachable via state (this script):
#   trial <state>        force the trial: active | expired | unknown | <N-days-ago>
#   updates-expired      set Pro-updates entitlement to expired (yesterday)
#   clear-purchase-cache drop RevenueCat's cached purchaser info (forces re-fetch)
#   status               print current dev-relevant state, change nothing
#
# NOT reachable this way (ephemeral @State inside the dev view — menu only):
#   debug-logging toggle, force-Intel simulation, the "simulate relaunch" action.
#   (The relaunch flow can be reproduced: `trial expired` then relaunch.)
#
# Options: --relaunch   reopen Juicy after the change
#
# Examples:
#   ./juicy-dev.sh trial expired --relaunch
#   ./juicy-dev.sh trial active
#   ./juicy-dev.sh trial 2            # started 2 days ago (1 day left)
#   ./juicy-dev.sh updates-expired
#   ./juicy-dev.sh clear-purchase-cache
#   ./juicy-dev.sh status
#
set -euo pipefail

BUNDLE_ID="io.sevendegrees.juicy.direct"
APP_NAME="Juicy"
TRIAL_FILE="$HOME/Library/Application Support/Juicy/.trial"
TRIAL_DAYS=3   # trial length, for "days remaining" display only

RELAUNCH=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --relaunch) RELAUNCH=1 ;;
    -h|--help)  grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) ARGS+=("$a") ;;
  esac
done
[[ ${#ARGS[@]} -ge 1 ]] || { echo "need a command; see --help" >&2; exit 2; }
CMD="${ARGS[0]}"

quit_juicy() {
  if pgrep -xq "$APP_NAME"; then
    osascript -e "quit app \"$APP_NAME\"" 2>/dev/null || true
    for _ in $(seq 1 20); do pgrep -xq "$APP_NAME" || break; sleep 0.25; done
    if pgrep -xq "$APP_NAME"; then
      echo "!! $APP_NAME still running — quit it manually and retry." >&2; exit 1
    fi
  fi
}
flush() { killall cfprefsd 2>/dev/null || true; }
relaunch_if_asked() { [[ "$RELAUNCH" == 1 ]] && { echo "relaunching $APP_NAME"; open -a "$APP_NAME"; }; }

# Write trialStartDate (UserDefaults, as a Date) + .trial mirror (epoch seconds)
# to the same instant, N whole days in the past. N=0 => now.
set_trial_start() {
  local n="$1" epoch datestr
  epoch=$(date -u -v-"${n}"d +%s)
  datestr=$(date -u -r "$epoch" "+%Y-%m-%d %H:%M:%S +0000")
  defaults write "$BUNDLE_ID" trialStartDate -date "$datestr"
  printf '%s.0' "$epoch" > "$TRIAL_FILE"
  echo "  trial start set to ${n}d ago  ($datestr)"
}

show_status() {
  echo "== Juicy dev state =="
  echo "  trialStartDate        : $(defaults read "$BUNDLE_ID" trialStartDate 2>/dev/null || echo '(none)')"
  echo "  .trial file           : $( [[ -f $TRIAL_FILE ]] && cat "$TRIAL_FILE" || echo '(none)')"
  echo "  juicy_updates_expire_at: $(defaults read "$BUNDLE_ID" juicy_updates_expire_at 2>/dev/null || echo '(none)')"
  echo "  juicy_license_key     : $(defaults read "$BUNDLE_ID" juicy_license_key 2>/dev/null || echo '(none)')"
  echo "  developerModeVisible  : $(defaults read "$BUNDLE_ID" developerModeVisible 2>/dev/null || echo '(none)')  (note: app forces this to 0 at launch)"
}

case "$CMD" in
  status) show_status ;;

  trial)
    sub="${ARGS[1]:-}"; [[ -n "$sub" ]] || { echo "trial needs: active|expired|unknown|<N>" >&2; exit 2; }
    quit_juicy
    case "$sub" in
      active)  set_trial_start 0 ;;                       # full ~${TRIAL_DAYS} days left
      expired) set_trial_start $((TRIAL_DAYS + 1)) ;;      # started >trial length ago
      unknown) defaults delete "$BUNDLE_ID" trialStartDate 2>/dev/null || true
               rm -f "$TRIAL_FILE"; echo "  trial cleared -> UNKNOWN (fresh trial on next launch)" ;;
      ''|*[!0-9]*) echo "trial arg must be active|expired|unknown|<integer days>" >&2; exit 2 ;;
      *)       set_trial_start "$sub" ;;                   # N days ago
    esac
    flush; show_status; relaunch_if_asked ;;

  updates-expired)
    # Pro-updates entitlement expiry = yesterday. NOTE: verify the encoding matches
    # how the app reads this key (Date here); if it reads a TimeInterval/number, use
    # `defaults write ... juicy_updates_expire_at -float <epoch>` instead.
    quit_juicy
    y=$(date -u -v-1d "+%Y-%m-%d %H:%M:%S +0000")
    defaults write "$BUNDLE_ID" juicy_updates_expire_at -date "$y"
    echo "  juicy_updates_expire_at set to yesterday ($y)"
    flush; relaunch_if_asked ;;

  clear-purchase-cache)
    quit_juicy
    # RevenueCat caches purchaser info in its own suite inside the app's defaults.
    for k in $(defaults read "$BUNDLE_ID" 2>/dev/null \
               | grep -oE 'com\.revenuecat\.userdefaults\.[A-Za-z0-9._]+' | sort -u); do
      defaults delete "$BUNDLE_ID" "$k" 2>/dev/null && echo "  cleared $k" || true
    done
    echo "  RevenueCat purchaser cache cleared (use Restore Purchase to repopulate)"
    flush; relaunch_if_asked ;;

  *) echo "unknown command: $CMD (see --help)" >&2; exit 2 ;;
esac
