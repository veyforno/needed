#!/usr/bin/env bash

# Mendapatkan tingkat kecerahan saat ini menggunakan brightnessctl
CURRENT=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

# Menampilkan Rofi dan meminta input angka (0-100)
# Menyertakan beberapa opsi default sebagai referensi
CHOICE=$(echo -e "10\n30\n50\n80\n100" | rofi -dmenu -p "Kecerahan Saat Ini: $CURRENT%" -mesg "Masukkan angka 0-100 untuk mengubah brightness")

# Validasi jika user memasukkan angka (0-100)
if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -le 100 ]; then
    brightnessctl set "${CHOICE}%"
fi
