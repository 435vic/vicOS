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

argparse 'e/edit' 'f/force' 'd-dir=?!test -d "$_flag_value"' -- $argv
or invalid_args

set -q _flag_dir; or set -l _flag_dir "$DOTFILES_HOME"
echo "$_flag_dir"

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
    echo "Do you want to add all untracked files to the commit? [y/N] "
    read -n 1 add_untracked
    if test "$add_untracked" = "y"
        #TODO: do this for real
        echo git add .
    end
end
if test -n git_status

end

echo "donezo"

