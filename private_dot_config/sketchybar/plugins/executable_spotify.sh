#!/bin/bash
# Spotify pill. Updates from Spotify's own playback notification, checks every
# 30s in case Spotify quit, and handles the control clicks.
# Every osascript call checks Spotify is running first, or it would launch it.

ITEMS=(spotify spotify.rule spotify.prev spotify.toggle spotify.next)

running() { pgrep -xq Spotify; }

case "$1" in
  prev) running && osascript -e 'tell application "Spotify" to previous track'; exit 0 ;;
  next) running && osascript -e 'tell application "Spotify" to next track'; exit 0 ;;
  playpause) running && osascript -e 'tell application "Spotify" to playpause'; exit 0 ;;
esac

if [ "$SENDER" = "spotify_change" ]; then
  TRACK="$(jq -r '.Name // empty' <<<"$INFO")"
  ARTIST="$(jq -r '.Artist // empty' <<<"$INFO")"
  STATE="$(jq -r '."Player State" // empty' <<<"$INFO")"
elif running; then
  IFS='|' read -r TRACK ARTIST STATE < <(osascript -e 'tell application "Spotify" to (name of current track) & "|" & (artist of current track) & "|" & (player state as string)')
fi
STATE="$(tr '[:upper:]' '[:lower:]' <<<"$STATE")"

args=()
if [ -z "$TRACK" ] || [ "$STATE" = "stopped" ]; then
  for item in "${ITEMS[@]}"; do args+=(--set "$item" drawing=off); done
  sketchybar "${args[@]}"
  exit 0
fi

if [ "$STATE" = "playing" ]; then
  TOGGLE=􀊅 SCROLL=on
else
  TOGGLE=􀊃 SCROLL=off
fi

for item in "${ITEMS[@]}"; do args+=(--set "$item" drawing=on); done
sketchybar "${args[@]}" \
           --set spotify label="$TRACK  ·  $ARTIST" scroll_texts=$SCROLL \
           --set spotify.toggle icon=$TOGGLE
