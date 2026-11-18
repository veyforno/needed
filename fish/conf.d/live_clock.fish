function __clock_repaint --on-signal SIGUSR1
    commandline -f repaint 2>/dev/null
end

if status is-interactive
    fish -c 'while kill -0 $argv[1] 2>/dev/null; sleep 1; kill -USR1 $argv[1]; end' $fish_pid &
    disown
end
