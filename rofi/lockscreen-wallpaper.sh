#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallpapers/"

if [ ! -d "$WALL_DIR" ]; then
  notify-send "Wallpaper selector" "Directory not found: $WALL_DIR"
  exit 1
fi

SELECTED=$(
  find -L "$WALL_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) |
    sort |
    while IFS= read -r file; do
      printf '%s\0icon\x1f%s\n' "$(basename "$file")" "$file"
    done |
    rofi -dmenu -i -p "Wallpaper" -show-icons \
      -theme-str '
                window { width: 45%; }
                listview { columns: 3; lines: 2; spacing: 10px; fixed-columns: true; }
                element { orientation: vertical; padding: 6px; }
                element-icon { size: 8em; horizontal-align: 0.5; }
                element-text { enabled: false; }
            '
)

# Esc -> quit
[ -z "$SELECTED" ] && exit 0

FULL_PATH="$WALL_DIR/$SELECTED"
betterlockscreen -u "$FULL_PATH"
