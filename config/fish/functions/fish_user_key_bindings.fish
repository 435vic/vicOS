function fish_user_key_bindings
    bind ctrl-f 'sesh picker --hide-duplicates --separator-aware; commandline -f repaint'
    bind -M insert ctrl-f 'sesh picker --hide-duplicates --separator-aware; commandline -f repaint'
end
