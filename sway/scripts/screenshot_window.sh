#!/bin/bash

rects=$(swaymsg -t get_tree | jq -r '
  [recurse(.nodes[]?, .floating_nodes[]?)
   | select(.type == "con" and (.pid? != null) and (.visible == true) and ((.nodes | length) == 0) and ((.floating_nodes | length) == 0))
   | .rect
   | select(.width > 0 and .height > 0)
   | "\(.x),\(.y) \(.width)x\(.height)"]
  | unique[]
')

[ -n "$rects" ] || exit 1

selection=$(printf '%s\n' "$rects" | slurp) || exit 0
[ -n "$selection" ] || exit 0

grim -g "$selection" - | swappy -f -
