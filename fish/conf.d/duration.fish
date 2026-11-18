# Convert milliseconds to "Xh YYm ZZs"
function __format_duration
    set -l total (math "floor($argv[1] / 1000)")
    set -l h (math "floor($total / 3600)")
    set -l m (math "floor(($total % 3600) / 60)")
    set -l s (math "$total % 60")
    printf '%dh %02dm %02ds' $h $m $s
end

# Runs automatically after every command finishes
function __show_duration --on-event fish_postexec
    # only show for commands that took 1 second or more
    if test $CMD_DURATION -ge 1000
        set_color brblack
        echo 'took '(__format_duration $CMD_DURATION)
        set_color normal
    end
end
