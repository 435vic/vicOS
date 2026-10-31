if status is-interactive
    set -g fish_greeting
    set -g fish_key_bindings fish_vi_key_bindings

    alias ls eza
    alias cat bat
    alias grep rg

    direnv hook fish | source
    zoxide init fish | source
    starship init fish | source
end
