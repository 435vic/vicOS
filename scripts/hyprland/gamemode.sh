# hyprctl --batch "\
#         keyword animations:enabled 0;\
#         keyword decoration:drop_shadow 0;\
#         keyword decoration:blur:enabled 0;\
#         keyword general:gaps_in 2;\
#         keyword general:gaps_out 2;\
#         keyword general:border_size 1;\
#         keyword decoration:rounding 0"

GAMEMODEFILE="/tmp/hyprgamemode"

if [ ! -f "$GAMEMODEFILE" ]; then
    echo "off" > "$GAMEMODEFILE"
fi

GAMEMODE=$(cat "$GAMEMODEFILE")

if [ "$GAMEMODE" == "off" ]; then
    EXTMONITOR=$(hyprctl monitors all -j | jq -r '.[] | select(.id == 1) | .name')
    hyprctl --batch "keyword monitor eDP-1,disabled; keyword monitor $EXTMONITOR,preferred,0x0,1"
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 2;\
        keyword general:gaps_out 2;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
    echo "on" > "$GAMEMODEFILE"
    notify-send -t 2500 "Game mode enabled"
    exit
else
    hyprctl reload
    echo "off" > "$GAMEMODEFILE"
    notify-send -t 2500 "Game mode disabled"
    exit
fi
