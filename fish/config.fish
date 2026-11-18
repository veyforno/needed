if status is-interactive
    set -g shell_integration enabled
end
function fish_greeting
    /home/nanoarch/fetchku/myfetchpng1
end
if not set -q SSH_AUTH_SOCK
    ssh-agent -c | source >/dev/null
end

#alliases
alias cls="clear"
alias la="ls -a"

#abbreviations
abbr -a ga 'git add'
abbr -a gcm 'git commit -m'
abbr -a gpu 'git push -u origin'
abbr -a coding 'cd ~/belajar_koding/'

#function
function nontonanime
    cd /mnt/windows/Users/Hype/Videos/anime/
    yazi .
end
function mangoconf
    cd ~/.config/mango
    nvim .
end
function fishconf
    cd ~/.config/fish
    nvim .
end
function waybarconf
    cd ~/.config/waybar/
    nvim .
end
function wific
    if test (count $argv) -ge 2
        nmcli device wifi connect $argv[1] password $argv[2]
    else
        nmcli device wifi connect $argv[1]
    end
end
function wifil
    nmcli d w
end
function wifid
    nmcli d disconnect wlp2s0
end
function quickconf
    cd ~/.config/quickshell
    nvim .
end
function roficonf
    cd ~/.config/rofi/
    nvim .
end
function ts
    ping google.com
    ping youtube.com
end
function nontonvideo
    cd ~/Video
    yazi .
end
function ytdlm
    echo holla kids there is music directory
    sleep 1.4
    cd $HOME/Music/
    yt-dlp -x --audio-format mp3 $argv[1]
end
function ytdlv
    echo holla kids there is Video directory
    sleep 1.4
    cd $HOME/Video/
    yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]' $argv[1]
end
function sddmconf
    cd /usr/share/sddm/
    sudo nvim .
end
function hyprconf
    cd ~/.config/hypr
    nvim .
end

# opencode
fish_add_path /home/nanoarch/.opencode/bin
