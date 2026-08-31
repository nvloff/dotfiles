#!/bin/sh
# Auto-float hook for on-window-detected (see aerospace.toml).
#
# Workspaces 4 and 5 are meant to behave like normal, non-tiled macOS window
# management. AeroSpace has no built-in "this workspace defaults to
# floating" setting -- on-window-detected can only match on the window/app
# itself, not on which workspace it's about to land on. So instead this
# looks up the newly-detected window's actual workspace after the fact and
# floats it if that's 4 or 5.
#
# EXPERIMENTAL -- built from AeroSpace's docs, not tested live:
#   - Relies on AEROSPACE_WINDOW_ID being set in this process's environment
#     (confirmed in AeroSpace's guide.adoc).
#   - Relies on %{window-id} being a valid `list-windows --format`
#     placeholder (NOT explicitly confirmed in the docs as of writing --
#     if this never fires, that's the first thing to check).
# Failure mode is harmless either way: if either assumption is wrong, this
# just silently does nothing and windows land tiled as before -- it can't
# float something incorrectly.
#
# Debug: tail -f /tmp/aerospace-autofloat.log

LOG=/tmp/aerospace-autofloat.log

{
  echo "$(date): window $AEROSPACE_WINDOW_ID detected"
  for ws in 4 5; do
    if aerospace list-windows --workspace "$ws" --format "%{window-id}" 2>&1 | grep -qx "$AEROSPACE_WINDOW_ID"; then
      echo "$(date): window $AEROSPACE_WINDOW_ID is on workspace $ws -- floating it"
      aerospace layout floating
      exit 0
    fi
  done
  echo "$(date): window $AEROSPACE_WINDOW_ID not on workspace 4/5 -- leaving tiled"
} >> "$LOG" 2>&1
