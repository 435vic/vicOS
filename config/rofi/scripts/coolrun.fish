#!/usr/bin/env fish

set -g coolrun_debug;

# cool debugging
function debug
  if set -q coolrun_debug
    notify-send "coolrun_debug" "$argv" -t 3800
  end
end

# TODO: Refactor
# - one core function coolrun that processes a command - nixrun nixpkgs#staruml, trun echo "hello world", nixpkg staruml, etc.
# - each submenu or stage sets a prefix - calculated by get_prefix. Based on $ROFI_INFO $ROFI_RETV $ROFI_DATA
# - The prompt tells the user what the prefix will be
# - At any point the user can bypass the prefix by starting the text with @
# - The data tag has two values separated by a pipe:
#   - The first value is the prefix for the 'parent' menu. Helps with navigation.
#   - The second value is the prefix for the current menu. Used on custom options (and listed options without an info tag)
# - The info tag overrides the prefix for the current menu. Useful for nixsearch opening the package details submenu.
#

# utility for making a rofi entry
function make_entry
  argparse 'name=' 'display=' 'icon=' 'info=' 'n/nonselectable' -- $argv

  echo -en "$_flag_name\0icon\x1f<span color='#7EBAE4' font='Symbols Nerd Font Mono 4'>$_flag_icon</span>"
  set -ql _flag_display; and echo -en "\x1fdisplay\x1f$_flag_display"
  set -ql _flag_info; and echo -en "\x1finfo\x1f$_flag_info"
  set -ql _flag_n; and echo -en "\x1fnonselectable\x1ftrue"
  echo -en "\n"
end

# jq filter that formats a package entry provided by nix-search-cli
function nixsearch_genentry
  echo -n "\""
  # entry ID
  echo -n "\(.package_attr_name)"
  # icon
  echo -n "\u0000icon\u001f<span color='#7EBAE4' font='Symbols Nerd Font Mono 4'>󰏗</span>"
  # display
  echo -n "\u001fdisplay\u001f\(.package_attr_name)<span font='JetBrains Mono 8'>  name: \(.package_pname) (\(.package_pversion))</span>&#x0a;"
  echo -n "<span font='Lexend 10'>\(.package_description)</span>"
  # meta
  echo -n "\u001fmeta\u001f\(.package_pname) \(.package_description) \(.package_attr_name) \(.package_attr_set)"
  echo -n "\n\""
end

# jq filter to show package overview in the message box
function nixpkg_geninfo
  echo -n "<span font-weight='bold' font='JetBrains Mono 16'>\(.package_attr_name)</span>"
  echo -n "<span font='JetBrains Mono 10'> via \(.package_pname) (\(.package_pversion))</span>&#x0a;"
  echo -n "<span font='JetBrainsMono 12'>\(.package_description)</span>&#x0a;"
end

function rofi_start
  # Normally $ROFI_DATA, set by the data tag here, determines the subcommand
  # that will handle rofi's output. However, we want to use it here to detect
  # if the command was launched from the main menu. The 'run' prefix
  # is optional ONLY in the top level (as to prevent conflicts with other subcommands)
  # Prefixing the data with an underscore will make all subcommand checks act as if it was never set.
  echo -e "\0data\x1f_coolrun"
  echo -e "\0prompt\x1fcoolrun"

  # help message activated by the help submenu
  if test $argv[1] -eq 1
    echo -en "\0message\x1f"
    echo -n "Choose an option with the arrow keys or type the command directly. Examples:&#x0a;"
    echo -n "<span font_weight='bold'>trun ping google.com</span>         # Ping google in the command line&#x0a;"
    echo -n "<span font_weight='bold'>nixrun nixpkgs#hello</span>         # Run the hello package from nixpkgs&#x0a;"
    echo -n "<span font_weight='bold'>(run) notify-send \"testing!\"</span> # Send a notification (prefix optional)&#x0a;"
    echo -e "<span font_weight='bold' underline='double'>Every submenu allows nixrun and trun!</span> so go nuts :)&#x0a;"
  end
  make_entry --name=nixrun --display="Run a flake package (nixrun)" --icon=""
  make_entry --name=nixsearch --display="Search nixpkgs for a package (nixsearch)" --icon=""
  make_entry --name=nixpkg --display="Inspect a nixpkgs package (nixpkg)" --icon="󱝪"
  make_entry --name=trun --display="Run a command in a terminal (trun)" --icon=""
  make_entry --name=run --display="Run a command silently" --icon="󰜎"
  test $argv[1] -eq 1
  or make_entry --name=help --display="Help" --icon=""
end

function crun_cmdnotfound
  echo -en "\0message\x1f"
  echo -n "<span font_weight='bold' font='JetBrains Mono 12'>Command $argv[1] not found!</span>&#x0a;";
  echo -n "Check the command and type again, or choose 'help'.&#x0a;";
  echo -n "Were you trying to exec a command without 'run'? Running commands without 'run' is only supported on the main menu.\n"
  make_entry --name="help" --display="Go back to the main menu" --icon="󰩈"
end

function handle_option
  # ignore the data parameter if it starts with an underscore
  if set -qx ROFI_DATA; and not string match -q "_*" $ROFI_DATA
    # this if allows us to open the nixpkg submenu from the nixsearch submenu
    handle_command (string split " " $argv)
    return 0
  end

  switch $argv
  case nixrun
    echo -e "\0prompt\x1fnixrun"
    echo -e "\0data\x1fnixrun"
    make_entry --nonselectable --name="Type a package to run..." --icon="󰏗"
  case trun
    echo -e "\0prompt\x1ftrun"
    echo -e "\0data\x1ftrun"
    make_entry  --nonselectable --name="Type a command to run in the terminal..." --icon=""
  case run
    echo -e "\0prompt\x1frun"
    echo -e "\0data\x1frun"
    make_entry --nonselectable --name="Type a command to run..." --icon="󰜎"
  case nixsearch
    echo -e "\0prompt\x1fnixsearch"
    echo -e "\0data\x1fnixsearch"
    make_entry --nonselectable --name="Type a package to search for..." --icon=""
  case help
    rofi_start 1
  end
end

function crun_nixrun
  set -l package $argv[1]

  set -l result_path (nix build --impure --dry-run --json $package | jq -er '.[].outputs.out')
  if test $status -ne 0
    notify-send "nixrun" "Package $package not found!" -t 8000
    return 1
  end

  if not test -e $result_path
    notify-send "nixrun" "Building $package..." -t 3000
    # show build logs on the terminal
    ghostty --title="nixrun - building $package..." -e nix build --impure --no-link $package
  end

  notify-send "nixrun" "Running $package..." -t 3000
  setsid nix run --impure $argv &>/dev/null &
end

function crun_nixsearch
  set -l nix_system (nix eval --raw --impure --expr 'builtins.currentSystem')
  echo -e "\0prompt\x1fnixsearch"
  # direct any option selection to nixpkg submenu
  echo -e "\0data\x1fnixpkg"
  echo -e "\0markup-rows\x1ftrue"
  set -l query_results (nix-search --json --search="$argv" --query-string="package_platforms:\"$nix_system\"")

  if test -n "$query_results"
    echo $query_results | jq -r (nixsearch_genentry)
  else
    make_entry --nonselectable --name=nixsearch --display="No results found for \"$argv\"" --icon="󱝪"
  end
end

function handle_command
  # Each 'subcommand' can be invoked directly or through its rofi submenu
  if set -qx ROFI_DATA; and not string match -q "_*" $ROFI_DATA
    set -f crun_command $ROFI_DATA
    set -f crun_args $argv
  else
    set -f crun_command $argv[1]
    set -f crun_args $argv[2..-1]
  end

  debug "running $crun_command, args: $crun_args"

  switch $crun_command
    case nixrun
      crun_nixrun $crun_args
    case trun
      setsid ghostty --title="trun - $crun_args" -e "$crun_args && fish --init-command='set -U fish_greeting'" &>/dev/null &
    case nixsearch
      crun_nixsearch $crun_args
    case nixpkg
      set -l pname $crun_args[1]
      set -l rofimsg "\"\u0000message\u001f$(nixpkg_geninfo)\n\""
      set -l query_results (nix-search --json --query-string="package_attr_name:\"$pname\"")
      echo -e "\0prompt\x1fcoolrun"
      if test -n "$query_results"
        echo $query_results | jq -r $rofimsg
        make_entry --name=nixpkgrun --display="Run package without arguments" --icon="󰜎"
      else
        make_entry --name=nixsearch --display="No results found for \"$pname\"" --icon="󱝪"
      end
    case 'run'
      setsid sh -c "$argv" &
    case '*'
      # the 'run' prefix is optional ONLY in the top scope
      if test $ROFI_DATA -eq "_coolrun"
        setsid sh -c "$argv" &
      else
        crun_cmdnotfound $argv
      end
  end
end

switch $ROFI_RETV
case 0 # first invocation
  rofi_start
case 1 # An option provided by the script was selected - interpret depending on context
  handle_option $argv
case 2 # A custom option was selected - interpret as a coolrun command
  handle_command (string split " " $argv)
end
