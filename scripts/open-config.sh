#!/usr/bin/env bash
# Open the notification config file in the user's editor
# Creates default config if it doesn't exist

set -euo pipefail

CONFIG_DIR="$HOME/.claude/notify"
CONFIG_FILE="$CONFIG_DIR/config"
SCRIPT_DIR="$(dirname "$0")"

# Create config with defaults if it doesn't exist
if [[ ! -f "$CONFIG_FILE" ]]; then
  mkdir -p "$CONFIG_DIR"
  cp "$SCRIPT_DIR/default-config.sh" "$CONFIG_FILE"
  echo "Created default config: $CONFIG_FILE"
fi

# Open in editor (ordered by priority, vim last as fallback)
if [[ -n "${EDITOR:-}" ]]; then
  "$EDITOR" "$CONFIG_FILE"
elif command -v code &>/dev/null; then
  code "$CONFIG_FILE"
elif command -v cursor &>/dev/null; then
  cursor "$CONFIG_FILE"
elif command -v zed &>/dev/null; then
  zed "$CONFIG_FILE"
elif command -v subl &>/dev/null; then
  subl "$CONFIG_FILE"
elif command -v idea &>/dev/null; then
  idea "$CONFIG_FILE"
elif command -v webstorm &>/dev/null; then
  webstorm "$CONFIG_FILE"
elif command -v pycharm &>/dev/null; then
  pycharm "$CONFIG_FILE"
elif command -v goland &>/dev/null; then
  goland "$CONFIG_FILE"
elif command -v phpstorm &>/dev/null; then
  phpstorm "$CONFIG_FILE"
elif command -v nvim &>/dev/null; then
  nvim "$CONFIG_FILE"
elif command -v emacs &>/dev/null; then
  emacs "$CONFIG_FILE"
elif command -v nano &>/dev/null; then
  nano "$CONFIG_FILE"
elif command -v vim &>/dev/null; then
  vim "$CONFIG_FILE"
elif command -v open &>/dev/null; then
  open "$CONFIG_FILE"
elif command -v xdg-open &>/dev/null; then
  xdg-open "$CONFIG_FILE"
else
  echo "No editor found. Please open manually: $CONFIG_FILE"
fi
