function help
    echo "dude sync - sync configuration with current machine"
    echo ""
    echo "arguments:"
    echo "  -e/--edit: open dotfiles in editor before syncing"
    echo "  -f/--fast: automatically create commit message"
    echo "  -m/--message: provide message for git commit"
end

function invalid_args
    echo "Invalid arguments."
    help
    exit 1
end

argparse -x f,m 'e/edit' 'f/fast' 'm/message=' 'd-dir=?!test -d "$_flag_value"' -- $argv
or invalid_args

set -q _flag_dir; or set -l _flag_dir "$DOTFILES_HOME"

if not test -d "$_flag_dir/.git"
    echo "ERROR: $_flag_dir is not a git repository."
    echo "Are you sure you specified the right directory?"
end

cd $_flag_dir

if set -q _flag_edit
    vim .
    git diff -U0 'config/' '*.nix' 'dude/'
end

set git_status (git status --porcelain)
set git_untracked (git status --porcelain | rg '^\?\?')

if test -n "$git_untracked" 
    echo "There are untracked files:"
    for file in $git_untracked
        echo $file
    end
    echo "You can add them all from this script."
    echo "To selectively add files, add them manually with git and rerun the script."
    read -P "Do you want to add all untracked files to the commit? [y/N] " -n 1 add_untracked
    if test "$add_untracked" = "y"
        git add .
    end
end

if test -n "$git_status"
    set -g git_commit
    if set -q _flag_fast
        git commit -am "[dude] $(hostname) sync from version $(nixos-version --configuration-revision)"
    else if set -q _flag_message
        git commit -am $_flag_message
    else
        git commit -a
    end
end

if test $status -ne 0 
    echo "commit cancelled, exiting"
    exit 1
end

function sync
    set -fx DOTFILES_HOME $argv[1]
    set sync_start (date +%s)
    sudo nixos-rebuild-ng switch --impure --flake git+file:$argv[1]?submodules=1
    and set sync_time (math (date +%s) - $sync_start)
end

if not sync $_flag_dir
    notify-send -t 4000 "dude sync" "Error while syncing!"
    if set -gq git_commit
        echo "Reverting last commit..."
        git reset --soft HEAD^1
    end
    exit 1
end

set generations (nixos-rebuild-ng list-generations --json)
set gen_number (echo $generations | jq -r '.[0].generation')
set gen_description (echo $generations | jq -r '"Gen \(.[0].generation) NixOS \(.[0].nixosVersion) Kernel \(.[0].kernelVersion)"')
git tag -a "$(hostname)-gen-$gen_number" -m "$gen_description" 

notify-send --icon=software-update-available "dude sync" "sync successful! took $sync_time"s

echo "donezo. took $sync_time"s

