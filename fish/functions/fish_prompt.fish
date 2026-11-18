function fish_prompt
    # username
    set_color --bold B9D4E3
    echo -n $USER

    # directory (full path, ~ for home)
    set_color B9D4E3
    echo -n ' '(prompt_pwd -d 1)

    # arrow
    set_color --bold B9D4E3
    echo -n '> '

    set_color normal
end
