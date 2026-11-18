#!/usr/bin/env bash

# Opsi Ikon Utama (Menggunakan Nerd Fonts)
shutdown="⏼"
reboot=""
lock=""

# 1. Pilih Aksi Utama
chosen=$(echo -e "$shutdown\n$reboot\n$lock" | rofi -dmenu -theme ~/.config/rofi/powermenu.rasi)

# Fungsi untuk meminta password via Rofi jika user memilih Shutdown/Reboot
minta_password() {
  bspc rule -a kitty-pass -o state=floating rectangle=666x666+555+555 center=true

  # 2. Panggil Kitty dengan class "kitty-pass" dan eksekusi perintah internal shell
  #    untuk menyembunyikan ketikan (stty -echo) lalu menangkap teksnya.
  kitty --class="kitty-pass" \
    --title="Sudo Password Required" \
    -o remember_window_size=no \
    sh -c 'stty -echo && echo -n "Masukkan Password Sudo: " && read -r pass && echo "$pass" > /tmp/sudo_pass_tmp'

  # 3. Ambil password yang tersimpan di file sementara, lalu hapus filenya demi keamanan
  if [ -f /tmp/sudo_pass_tmp ]; then
    cat /tmp/sudo_pass_tmp
    rm /tmp/sudo_pass_tmp
  fi
}

case "$chosen" in
"$shutdown" | "$reboot")
  # 2. Jika memilih shutdown/reboot, minta password terlebih dahulu
  pass=$(minta_password)

  # 3. Verifikasi apakah password benar menggunakan sudo -S (membaca dari stdin)
  if echo "$pass" | sudo -S -v &>/dev/null; then
    if [ "$chosen" = "$shutdown" ]; then
      echo "$pass" | sudo -S systemctl poweroff
    else
      echo "$pass" | sudo -S systemctl reboot
    fi
  else
    # Jika password salah, tampilkan pesan error singkat di Rofi
    rofi -e "Password salah atau dibatalkan!"
  fi
  ;;

"$lock")
  # Mengunci layar tidak membutuhkan password sudo
  Betterlockscreen -l dimblur --fx fade
  ;;
esac
