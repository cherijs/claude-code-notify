#!/usr/bin/env bash
# Play notification sound when Claude needs attention.
#
# Configuration: ~/.claude/notify/config
# Run with --init to create default config
#
# Cross-platform: macOS, Linux, Windows (Git Bash/WSL)

set -euo pipefail

CONFIG_DIR="$HOME/.claude/notify"
CONFIG_FILE="$CONFIG_DIR/config"
SCRIPT_DIR="$(dirname "$0")"

# Session ID for per-session toggle (terminal-specific IDs are most reliable)
SESSION_ID="${WT_SESSION:-${TERM_SESSION_ID:-${KONSOLE_DBUS_SESSION:-${TMUX_PANE:-${WINDOWID:-global}}}}}"
SESSION_FILE="$CONFIG_DIR/.disabled-$SESSION_ID"

# Handle flags
case "${1:-}" in
  --init)
    mkdir -p "$CONFIG_DIR"
    if [[ -f "$CONFIG_FILE" ]]; then
      echo "Config already exists: $CONFIG_FILE"
    else
      cp "$SCRIPT_DIR/default-config.sh" "$CONFIG_FILE"
      echo "Created config: $CONFIG_FILE"
    fi
    exit 0
    ;;
  --toggle-session)
    mkdir -p "$CONFIG_DIR"
    if [[ -f "$SESSION_FILE" ]]; then
      rm "$SESSION_FILE"
      echo "Notifications enabled for this session"
    else
      touch "$SESSION_FILE"
      echo "Notifications disabled for this session"
    fi
    exit 0
    ;;
  --toggle-global)
    mkdir -p "$CONFIG_DIR"
    if [[ ! -f "$CONFIG_FILE" ]]; then
      cp "$SCRIPT_DIR/default-config.sh" "$CONFIG_FILE"
    fi
    if grep -q '^NOTIFY_ENABLED="false"' "$CONFIG_FILE" 2>/dev/null; then
      sed -i.bak 's/^NOTIFY_ENABLED="false"/NOTIFY_ENABLED="true"/' "$CONFIG_FILE" && rm -f "$CONFIG_FILE.bak"
      echo "Notifications enabled globally"
    elif grep -q '^NOTIFY_ENABLED=' "$CONFIG_FILE" 2>/dev/null; then
      sed -i.bak 's/^NOTIFY_ENABLED=.*/NOTIFY_ENABLED="false"/' "$CONFIG_FILE" && rm -f "$CONFIG_FILE.bak"
      echo "Notifications disabled globally"
    else
      echo 'NOTIFY_ENABLED="false"' >> "$CONFIG_FILE"
      echo "Notifications disabled globally"
    fi
    exit 0
    ;;
  --status)
    echo "Session: $(if [[ -f "$SESSION_FILE" ]]; then echo "DISABLED"; else echo "enabled"; fi)"
    # shellcheck source=/dev/null
    [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
    echo "Global:  $(if [[ "${NOTIFY_ENABLED:-true}" == "true" ]]; then echo "enabled"; else echo "DISABLED"; fi)"
    exit 0
    ;;
esac

# Check if disabled (session or global)
if [[ -f "$SESSION_FILE" ]]; then
  exit 0
fi

# Defaults
NOTIFY_ENABLED="true"
NOTIFY_SOUND=""  # Empty = use platform default (Hero.aiff on macOS, etc.)
NOTIFY_TMUX_SPEECH="false"
NOTIFY_TMUX_VOICE="Samantha"
NOTIFY_TMUX_SPEECH_RATE=350
NOTIFY_TMUX_SPEECH_PREFER="auto"  # "auto", "number", or "name"
NOTIFY_TMUX_WINDOW_PATTERN="{n}"
NOTIFY_TMUX_NAME_PATTERN="{name}"

# Load config if exists
# shellcheck source=/dev/null
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# Check if globally disabled
if [[ "$NOTIFY_ENABLED" != "true" ]]; then
  exit 0
fi

# Detect platform
detect_platform() {
  case "$(uname -s)" in
    Darwin*) echo "macos" ;;
    Linux*)  echo "linux" ;;
    CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
    *)       echo "unknown" ;;
  esac
}

PLATFORM=$(detect_platform)

# Platform-specific default sounds
default_sound() {
  case "$PLATFORM" in
    macos)   echo "/System/Library/Sounds/Hero.aiff" ;;
    linux)   echo "/usr/share/sounds/freedesktop/stereo/complete.oga" ;;
    windows) echo "C:\\Windows\\Media\\chimes.wav" ;;
    *)       echo "" ;;
  esac
}

# Play sound (cross-platform)
play_sound() {
  local sound="${NOTIFY_SOUND:-$(default_sound)}"

  if [[ -z "$sound" ]]; then
    printf '\a'
    return
  fi

  case "$PLATFORM" in
    macos)
      afplay "$sound" &>/dev/null &
      ;;
    linux)
      if [[ -f "$sound" ]]; then
        if command -v paplay &>/dev/null; then
          paplay "$sound" &>/dev/null &
        elif command -v aplay &>/dev/null; then
          aplay "$sound" &>/dev/null &
        else
          printf '\a'
        fi
      else
        printf '\a'
      fi
      ;;
    windows)
      if command -v powershell.exe &>/dev/null; then
        powershell.exe -c "(New-Object Media.SoundPlayer '$sound').PlaySync()" &>/dev/null &
      else
        printf '\a'
      fi
      ;;
    *)
      printf '\a'
      ;;
  esac
}

# Speak helper (cross-platform)
speak() {
  local text="$1"
  case "$PLATFORM" in
    macos)
      say -v "$NOTIFY_TMUX_VOICE" -r "$NOTIFY_TMUX_SPEECH_RATE" "$text" &>/dev/null &
      ;;
    linux)
      if command -v spd-say &>/dev/null; then
        spd-say -r "$((NOTIFY_TMUX_SPEECH_RATE / 2 - 100))" -t "$NOTIFY_TMUX_VOICE" "$text" &>/dev/null &
      elif command -v espeak &>/dev/null; then
        espeak -v "$NOTIFY_TMUX_VOICE" -s "$NOTIFY_TMUX_SPEECH_RATE" "$text" &>/dev/null &
      fi
      ;;
    windows)
      if command -v powershell.exe &>/dev/null; then
        powershell.exe -c "Add-Type -AssemblyName System.Speech; \$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$s.SelectVoice('$NOTIFY_TMUX_VOICE'); \$s.Speak('$text')" &>/dev/null &
      fi
      ;;
  esac
}

# Main logic
if [[ "$NOTIFY_TMUX_SPEECH" == "true" ]] && [[ -n "${TMUX:-}" ]]; then
  # Tmux speech mode: speak window info instead of playing sound
  # Use TMUX_PANE to get window info for the pane where Claude started,
  # not the currently selected window
  pane_target="${TMUX_PANE:-}"
  if [[ -n "$pane_target" ]]; then
    window_num=$(tmux display-message -t "$pane_target" -p '#I' 2>/dev/null || echo "")
    window_name=$(tmux display-message -t "$pane_target" -p '#W' 2>/dev/null || echo "")
  else
    window_num=$(tmux display-message -p '#I' 2>/dev/null || echo "")
    window_name=$(tmux display-message -p '#W' 2>/dev/null || echo "")
  fi

  # Determine whether to use number or name based on preference
  use_number=false
  use_name=false

  case "$NOTIFY_TMUX_SPEECH_PREFER" in
    number)
      use_number=true
      ;;
    name)
      use_name=true
      ;;
    *)
      # Auto mode: use number for default shell names, name otherwise
      default_names="fish bash zsh sh tcsh csh ksh dash tmux"
      for name in $default_names; do
        [[ "$window_name" == "$name" ]] && use_number=true && break
      done
      [[ "$use_number" == false ]] && use_name=true
      ;;
  esac

  if [[ "$use_number" == true ]] && [[ -n "$window_num" ]]; then
    # Use window number pattern
    text="${NOTIFY_TMUX_WINDOW_PATTERN//\{n\}/$window_num}"
    speak "$text"
  elif [[ "$use_name" == true ]] && [[ -n "$window_name" ]]; then
    # Use window name pattern
    text="${NOTIFY_TMUX_NAME_PATTERN//\{name\}/$window_name}"
    speak "$text"
  fi
else
  # Normal mode: play sound
  play_sound
fi

exit 0
