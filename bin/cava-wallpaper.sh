#!/usr/bin/env bash
CLASS=cava-bg

start() {
  pgrep -f "class cava-bg" >/dev/null || \
    alacritty --class cava-bg -o window.opacity=0.80 -o font.size=11 -e cava &
  pgrep -f "class rmpc-bg" >/dev/null || \
    alacritty --class rmpc-bg -o window.opacity=0.80 -o font.size=11 -e rmpc &
}
stop() { pkill -f "class cava-bg"; pkill -f "class rmpc-bg"; }

while true; do
  playerctl -F status 2>/dev/null | while read -r s; do
    if [ "$s" = "Playing" ]; then start; else stop; fi
  done
  sleep 2
done
