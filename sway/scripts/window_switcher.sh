#!/bin/bash

# Define the lengths for each column
ws_length=2
app_id_length=14
name_length=50

# Fetch the data from swaymsg and format it
formatted_output=$(swaymsg -t get_tree | jq -r --arg ws_length "$ws_length" --arg app_id_length "$app_id_length" --arg name_length "$name_length" '
  def lpad($len; $char):
    if (.|length) > $len then $char * ($len - (.|length)) + .[:$len-1] + "\u2026" else $char * ($len - (.|length)) + . end;
  def rpad($len; $char):
    if (.|length) > $len then .[:$len-1] + "\u2026" else . + $char * ($len - (.|length)) end;
  def walk($ws):
    . as $node
    | (if $node.type == "workspace" then $node.name else $ws end) as $current_ws
    | (
        if $node.type == "con" and ($node.app_id != null or ($node.window_properties.class? != null)) and ($node.name != null) and (($node.nodes | length) == 0) and (($node.floating_nodes | length) == 0)
        then [{
          ws: $current_ws,
          focused: ($node.focused // false),
          app_id: ($node.app_id // $node.window_properties.class // "xwayland"),
          name: $node.name,
          id: $node.id
        }]
        else []
        end
      ) + [($node.nodes[]?, $node.floating_nodes[]?) | walk($current_ws)] | add;
  walk("")[]
  | (if .focused then "*" else " " end) as $asterisk
  | "\($asterisk)[\(.ws | lpad($ws_length | tonumber; " "))]\((.app_id // "xwayland") | lpad($app_id_length | tonumber; " ")): \(.name | rpad($name_length | tonumber; " ")) (\(.id))"
')

[ -n "$formatted_output" ] || exit 0

# Launch fuzzel with the formatted output
row=$(printf '%s\n' "$formatted_output" | fuzzel --dmenu --width=80 --lines=12)

# Get the container ID from the selection and focus the container
if [ -n "$row" ]; then
    winid=$(printf '%s\n' "$row" | sed -n 's/.*(\([0-9][0-9]*\))$/\1/p')
    if [ -n "$winid" ]; then
        swaymsg "[con_id=$winid] focus"
    fi
fi
