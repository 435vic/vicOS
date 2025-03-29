function help
    echo "dude sync - sync configuration with current machine"
    echo ""
    echo "arguments:"
    echo "  -e/--edit: open dotfiles in editor before syncing"
    echo "  -f/--fast: automatically create commit message"
end

function invalid_args
    echo "Invalid arguments."
    help
    exit 1
end

argparse 'e/edit' 'f/fast' 'd-dir=?!test -d "$_flag_value"' -- $argv
or invalid_args

set -q _flag_dir; or set -l _flag_dir "$DOTFILES_HOME"

if not test -d "$_flag_dir/.git"
    echo "ERROR: $_flag_dir is not a git repository."
    echo "Are you sure you specified the right directory?"
end

cd $_flag_dir

if set -q _flag_edit
    vim .
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
    if set -q _flag_fast
        git commit -am "[dude] $(hostname) sync from version $(nixos-version --configuration-revision)"
        set -g _dude_commit 1
    else
        git commit -a
    end
end

set -x DOTFILES_HOME $_flag_dir
if not sudo nixos-rebuild-ng switch --impure --flake git+file:$_flag_dir?submodules=1
    notify-send -t 4000 "dude sync" "Error while syncing!"
    if set -gq _dude_commit
        echo "Reverting auto commit..."
        git reset --soft HEAD^1
    end
    exit 1
end

set generations (nixos-rebuild-ng list-generations --json)
set gen_number (echo $generations | jq -r '.[0].generation')
set gen_description (echo $generations | jq -r '"Gen \(.[0].generation) NixOS \(.[0].nixosVersion) Kernel \(.[0].kernelVersion)"')
git tag -a "$(hostname)-gen-$gen_number" -m "$gen_description" 

echo "donezo"

