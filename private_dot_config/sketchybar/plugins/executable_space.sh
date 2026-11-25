#!/bin/bash
# The current Space on each screen gets the apricot number, brighter app icons
# and a 1px underline.

source "$CONFIG_DIR/colors.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" icon.color=$APRICOT icon.font="SF Pro:Regular:12.5" label.color=$TEXT background.drawing=on
else
  sketchybar --set "$NAME" icon.color=$MUTED icon.font="SF Pro:Light:12.5" label.color=$MUTED background.drawing=off
fi
