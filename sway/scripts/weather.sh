#!/bin/bash

LOC="${1:-NewYork}"
LOCATION="${LOC// /%20}"
WEATHER_URL="https://thisdavej.azurewebsites.net/api/weather/current?loc=${LOCATION}&deg=C"
ICON_URL='https://wttr.in/?format=1'

icon_file=$(mktemp)
trap 'rm -f "$icon_file"' EXIT

curl --silent --show-error --fail --connect-timeout 2 --max-time 4 "$ICON_URL" >"$icon_file" 2>/dev/null &
icon_pid=$!

text="N/A"
tooltip="Weather unavailable"
class="unavailable"

if content=$(curl --silent --show-error --fail --connect-timeout 3 --max-time 6 "$WEATHER_URL" 2>/dev/null); then
  if parsed=$(jq -r '[(.temperature | tostring) + "°" + .degType, ((.temperature | tostring) + "°" + .degType + "\\n" + .skytext), .skytext] | @tsv' <<<"$content" 2>/dev/null); then
    IFS=$'\t' read -r text tooltip class <<<"$parsed"
  fi
fi

wait "$icon_pid" 2>/dev/null || true
icon=$(sed 's/[+0-9a-cA-Z°-]//g' <"$icon_file" 2>/dev/null || true)

if [ -n "$icon" ]; then
  tooltip="$icon $tooltip"
fi
tooltip="$tooltip $LOC"

jq -n --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" '{text:$text, tooltip:$tooltip, class:$class}'
