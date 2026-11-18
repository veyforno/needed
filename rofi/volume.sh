!/bin/bash
wpctl set-volume @DEFAULT_AUDIO_SINK@ $(rofi -dmenu -p "Set Volume:")%
