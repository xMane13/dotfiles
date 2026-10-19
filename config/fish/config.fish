if status is-interactive
    set -g fish_greeting ""

    alias pls sudo
    alias cat 'batcat --paging=never'
    alias ls 'eza --icons=auto --group-directories-first'
    alias ll 'eza -l --icons=auto --group-directories-first --header --git'

    starship init fish | source
    zoxide init fish | source
    fzf --fish | source

    fastfetch
end
