#!/usr/bin/env fish

set -g coolrun_debug;

# cool debugging
function debug
  if set -q coolrun_debug
    notify-send "coolrun_debug" "$argv" -t 6000
  end
end

# utility for making a rofi entry
function make_entry
  argparse 'name=' 'display=' 'icon=' 'info=' 'n/nonselectable' -- $argv

  echo -en "$_flag_name\0icon\x1f<span color='#7EBAE4' font='Symbols Nerd Font Mono 4'>$_flag_icon</span>"
  set -ql _flag_display; and echo -en "\x1fdisplay\x1f$_flag_display"
  set -ql _flag_info; and echo -en "\x1finfo\x1f$_flag_info"
  set -ql _flag_n; and echo -en "\x1fnonselectable\x1ftrue"
  echo -en "\n"
end

function get_prefix
  set -l prefixes (string split '|' $ROFI_DATA)
  test -n "$(string trim $prefixes[1])"; and set -g _rofi_parent_prefix (string split ' ' $prefixes[1])
  test -n "$(string trim $prefixes[2])"; and set -g _rofi_prefix (string split ' ' $prefixes[2])
  set -qx ROFI_INFO; and set -g _rofi_prefix (string split ' ' $ROFI_INFO)
  debug "parent prefix: $_rofi_parent_prefix, prefix: $_rofi_prefix"
  # set -g $_rofi_parent_prefix (string split ' ' $prefixes[1])
  # set -g $_rofi_prefix (string split ' ' $prefixes[2])
end

function set_prefix
  echo -e "\0data\x1f$argv[1]|$argv[2]"
  test -z "$argv[3]"
  and echo -e "\0prompt\x1f$argv[2]"
  or echo -e "\0prompt\x1f$argv[3]"
end

function list_subcommands
  make_entry --name=nixrun --display="Run a flake package (nixrun)" --icon=""
  make_entry --name=nixsearch --display="Search nixpkgs for a package (nixsearch)" --icon=""
  make_entry --name=nixpkg --display="Inspect a nixpkgs package (nixpkg)" --icon="󱝪"
  make_entry --name=trun --display="Run a command in a terminal (trun)" --icon=""
  make_entry --name=run --display="Run a command silently" --icon="󰜎"
end

function subcommand_help
  set_prefix '' '' 'coolrun'

  echo -en "\0message\x1f"
  echo -en "Choose a subcommand to enter the menu or call it with arguments directly:&#x0a;"
  echo -en "<span font_weight='bold'>trun ping google.com</span>         # Ping google in the command line&#x0a;"
  echo -en "<span font_weight='bold'>nixrun nixpkgs#hello</span>         # Run the hello package from nixpkgs&#x0a;"
  echo -en "<span font_weight='bold'>(run) notify-send \"testing!\"</span> # Send a notification (prefix optional)&#x0a;"
  echo -en "You can invoke these commands from any submenu by prefixing them with '@'!&#x0a;"
  echo -en "The prompt will tell you under what subcommand your input will run.\n"

  list_subcommands
end

function __nixsearch_gen_entry
  # entry ID and info
  # submenu for custom entries is nixpkg
  echo -n "\(.package_attr_name)\u0000info\u001fnixpkg"
  # icon
  echo -n "\u001ficon\u001f<span color='#7EBAE4' font='Symbols Nerd Font Mono 4'>󰏗</span>"
  # display
  echo -n "\u001fdisplay\u001f\(.package_attr_name)<span font='JetBrains Mono 8'>  name: \(.package_pname) (\(.package_pversion))</span>&#x0a;"
  echo -n "<span font='Lexend 10'>\(.package_description)</span>"
  # meta
  echo -n "\u001fmeta\u001f\(.package_pname) \(.package_description) \(.package_attr_name) \(.package_attr_set)\n"
end

function subcommand_nixsearch
  # previous prefix is none (top level)
  # custom entries will be handled by nixsearch
  set_prefix '' 'nixsearch'

  if test -z "$argv"
    echo -en "\0message\x1f\n" # clear message
    make_entry --nonselectable --name=nixsearch --display="Type a search term..." --icon="󱝪"
    return 0
  end

  echo -e "\0markup-rows\x1ftrue"
  set -l nix_system (nix eval --raw --impure --expr 'builtins.currentSystem')
  set -l query_results (nix-search --json --search="$argv" --query-string="package_platforms:\"$nix_system\"")

  if test -n "$query_results"
    echo $query_results | jq -r "\"$(__nixsearch_gen_entry)\""
  else
    make_entry --nonselectable --name=__coolrun_nixsearch --display="No results found for \"$argv\"" --icon="󱝪"
  end
end

function __nixpkg_gen_info
  echo -en "\u0000message\u001f"
  echo -n "<span font-weight='bold' font='JetBrains Mono 16'>\(.package_attr_name)</span>"
  echo -n "<span font='JetBrains Mono 10'> via \(.package_pname) (\(.package_pversion))</span>&#x0a;"
  echo -n "<span font='JetBrainsMono 12'>\(.package_description)</span>&#x0a;"
  echo -en "\n"
end

function subcommand_nixpkg
  set_prefix 'nixsearch' 'nixsearch'

  if test -z "$argv"
    echo -en "\0message\x1f"
    echo -en "This subcommand is meant to be invoked with a specific package name.&#x0a;"
    echo -en "If you don't know the exact name, search for a package here first.\n"
    make_entry --nonselectable --name=__coolrun_nixpkg --display="Search for a package..." --icon="󱝪"
    return 0
  end

  set -l query_results (nix-search --json --search="$argv" --query-string="package_attr_name:\"$argv\"")
  # debug "query_results: $query_results"
  if test -n "$query_results"
    echo $query_results | jq -r "\"$(__nixpkg_gen_info)\""
    make_entry --name="@nixrun nixpkgs#$argv" --display="Run this package (nixrun)" --icon=""
  else
    make_entry --nonselectable --name=nixpkg --display="No results found for \"$argv\"" --icon="󱝪"
  end
end

function subcommand_nixrun
  set_prefix '' 'nixrun'
  if test -z "$argv"
    echo -en "\0message\x1f\n" # clear message
    make_entry --nonselectable --name=__coolrun_nixrun --display="Type a package to run..." --icon="󰏗"
    return 0
  end

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

function subcommand_trun
  set_prefix '' 'trun'
  if test -z "$argv"
    echo -en "\0message\x1f\n" # clear message
    make_entry --nonselectable --name=__coolrun_trun --display="Type a command to run in a terminal..." --icon=""
    return 0
  end

  setsid ghostty --title="trun - $argv" -e "$argv && fish --init-command='set -U fish_greeting'" &>/dev/null &
end

function subcommand_run
  set_prefix '' 'run'
  if test -z "$argv"
    echo -en "\0message\x1f\n" # clear message
    make_entry --nonselectable --name=__coolrun_run --display="Type a command to run..." --icon="󰜎"
    return 0
  end

  setsid sh -c "$argv" &>/dev/null &
end

function coolrun
  if string match -q "@*" $argv
    set -f command (string split ' ' (string match -rg '^@(.*)$' $argv))
    debug "@command: $command"
  else if test -n "$(string trim $argv)"
    get_prefix
    set -f command $_rofi_prefix (string split ' ' $argv)
    debug "prefixed command: $command"
  else
    set_prefix '' '' 'coolrun'
    list_subcommands
    make_entry --name=help --display="Help" --icon=""
    return 0
  end

  set -l subcommand $command[1]
  set -l args $command[2..-1]

  # debug "subcommand: $subcommand args: $args"

  switch $subcommand
  case help
    subcommand_help $args
  case nixsearch
    subcommand_nixsearch $args
  case nixpkg
    subcommand_nixpkg $args
  case nixrun
    subcommand_nixrun $args
  case trun
    subcommand_trun $args
  case run
    subcommand_run $args
  end
end

if set -qx ROFI_RETV
  coolrun $argv
else
  echo "ERROR: This is a rofi script. It is not meant to be launched from the terminal!"
  echo "Usage: rofi -show coolrun"
  return 1
end
