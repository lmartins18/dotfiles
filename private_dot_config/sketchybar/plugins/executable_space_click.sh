#!/bin/bash
# $1 is the Space number. Brings forward an app with a window on that Space
# (saved by space_windows.sh), and macOS switches there to show it. Finder is
# the last resort since it usually has windows everywhere. A Space with no
# windows has nothing to go to, so the click does nothing.

list="${TMPDIR:-/tmp}/sketchybar_space_$1"
[ -f "$list" ] || exit 0

while IFS= read -r app; do
  [ -n "$app" ] && open -a "$app" 2>/dev/null && exit 0
done < <(grep -vx Finder "$list"; grep -x Finder "$list")
