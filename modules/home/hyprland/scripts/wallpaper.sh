#!/usr/bin/env bash
wallpaper=$(ls ~/Wallpapers | walker --dmenu)

if [[ -n "$wallpaper" ]]; then
    ~/.local/bin/nixwal "$HOME/Wallpapers/$wallpaper"
fi
