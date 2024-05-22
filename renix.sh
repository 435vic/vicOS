
set -e

pushd ~/nixos-config

if [ "$1" != "-b" ]; then
	$EDITOR ${1:-"home.nix"}
	if [ "$?" -ne 0 ]; then
		echo "renix was cancelled :("
		popd
		exit 1
	fi
fi

if (git status '*.nix' --porcelain | grep '^??'); then
	echo "There are untracked files."
	echo "Add them with 'git add' and do renix -b to skip editing."
	exit 1
fi

if git diff --quiet '*.nix'; then
	echo "No changes detected, exiting."
	popd
	exit 0
fi

alejandra . &>/dev/null \
	|| ( alejandra . ; echo "Formatting failed!" && exit 1)

git diff -U0 '*.nix'

echo "reNixing now"

# sudo nixos-rebuild switch --flake &>nixos-switch.log || (cat nixos-switch.log | grep --color error && exit 1)

popd

notify-send -e "reNix successful :D" --icon=software-update-available

