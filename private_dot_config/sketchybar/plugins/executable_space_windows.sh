#!/bin/bash
# Puts small app icons (sketchybar-app-font) next to each Space number.
# SketchyBar sends space_windows_change for each Space as its windows change.
# The app names are also saved so a click on the Space number can go there
# (space_click.sh).

source "$CONFIG_DIR/plugins/icon_map.sh"

[ "$SENDER" = "space_windows_change" ] || exit 0

space="$(jq -r '.space' <<<"$INFO")"
apps="$(jq -r '.apps | keys[]' <<<"$INFO")"
printf '%s\n' "$apps" >"${TMPDIR:-/tmp}/sketchybar_space_$space"

icons=""
while IFS= read -r app; do
  [ -z "$app" ] && continue
  __icon_map "$app"
  icons+="$icon_result"
done <<<"$apps"

if [ -n "$icons" ]; then
  sketchybar --set space."$space" label="$icons" label.drawing=on
else
  sketchybar --set space."$space" label.drawing=off
fi
