#!/usr/bin/env sh

# Source: https://github.com/prasanthrangan/hyprdots

# Restores the shader after screenshot has been taken
restore_shader() {
    :
	# if [ -n "$shader" ]; then
	# 	hyprshade on "$shader"
	# fi
}

# Saves the current shader and turns it off
save_shader() {
    :
	# shader=$(hyprshade current)
	# hyprshade off
	# trap restore_shader EXIT
}

save_shader # Saving the current shader

if [ -z "$XDG_PICTURES_DIR" ]; then
	XDG_PICTURES_DIR="$HOME/Pictures"
fi

save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
temp_screenshot="/tmp/screenshot.png"

mkdir -p $save_dir

function print_error
{
	cat <<"EOF"
    ./screenshot.sh <action>
    ...valid actions are...
        p  : print all screens
        s  : snip current screen
        sf : snip current screen (frozen)
        m  : print focused monitor
EOF
}

case $1 in
p) # print all outputs
	grimblast copysave screen $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
s) # drag to manually snip an area / click on a window to print it
	grimblast copysave area $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
sf) # frozen screen, drag to manually snip an area / click on a window to print it
	grimblast --freeze copysave area $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
m) # print focused monitor
	grimblast copysave output $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
*) # invalid option
	print_error ;;
esac

rm "$temp_screenshot"
