# hyprctl --batch "\
#         keyword animations:enabled 0;\
#         keyword decoration:drop_shadow 0;\
#         keyword decoration:blur:enabled 0;\
#         keyword general:gaps_in 2;\
#         keyword general:gaps_out 2;\
#         keyword general:border_size 1;\
#         keyword decoration:rounding 0"

GAMEMODEFILE="/tmp/hyprgamemode"

# if the script is called with -r, reset gamemode

if [ "$1" == "-r" ]; then
    echo "off" > "$GAMEMODEFILE"
    exit
fi

if [ ! -f "$GAMEMODEFILE" ]; then
    echo "off" > "$GAMEMODEFILE"
fi

GAMEMODE=$(cat "$GAMEMODEFILE")

if [ "$GAMEMODE" == "off" ]; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 2;\
        keyword general:gaps_out 2;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
    echo "on" > "$GAMEMODEFILE"
    # Check if an external monitor is connected
    EXTMONITOR=$(hyprctl monitors all -j | jq -r '.[] | select(.id != 0) | .name' | head -n1)
    if [ -n "$EXTMONITOR" ]; then
        hyprctl --batch "keyword monitor eDP-1,disabled; keyword monitor $EXTMONITOR,preferred,0x0,1"
    else
        notify-send -t 2500 "No external monitor detected. Built-in display remains active."
    fi
    killall hypridle
    notify-send -t 2500 "Game mode enabled"
    exit
else
    hyprctl reload
    pgrep hypridle || hyprctl dispatch exec hypridle
    echo "off" > "$GAMEMODEFILE"
    notify-send -t 2500 "Game mode disabled"
    exit
fi
