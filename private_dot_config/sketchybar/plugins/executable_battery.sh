#!/bin/bash
# Adapted from github.com/wthrajat/dotfiles-mac.

source "$CONFIG_DIR/colors.sh"

BATT="$(pmset -g batt 2>/dev/null)"
PERCENTAGE="${BATT%%%*}"
PERCENTAGE="${PERCENTAGE##*[^0-9]}"
case "$PERCENTAGE" in ''|*[!0-9]*) exit 0 ;; esac

case $PERCENTAGE in
  [8-9][0-9]|100) ICON=􀛨 ;;
  [6-7][0-9]) ICON=􀺸 ;;
  [3-5][0-9]) ICON=􀺶 ;;
  [1-2][0-9]) ICON=􀛩 ;;
  *) ICON=􀛪 ;;
esac

LABEL_COLOR=$TEXT
if [[ "$BATT" == *"AC Power"* ]]; then
  ICON=􀋥
elif [ "$PERCENTAGE" -lt 20 ]; then
  LABEL_COLOR=$RED
fi

sketchybar --set "$NAME" icon=$ICON label="$PERCENTAGE%" label.color=$LABEL_COLOR
