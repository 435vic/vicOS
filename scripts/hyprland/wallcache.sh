
wallpaper="rainworldvinyl.png"

[ ! -e ~/vicOS/wall.thmb ] && magick ~/wallpapers/$wallpaper -strip -resize 1000 -gravity center -extent 1000 -quality 90 ~/.cache/vicOS/wall.thumb
[ ! -e ~/vicOS/wall.blur ] && magick -strip -scale 10% -blur 0x3 -resize 100% ~/.cache/vicOS/wall.blur
