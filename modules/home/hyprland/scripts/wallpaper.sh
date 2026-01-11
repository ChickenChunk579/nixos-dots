#!/usr/bin/env bash
wallpaper=$(ls ~/Wallpapers | walker --dmenu)

if [[ -n "$wallpaper" ]]; then
    ~/.nix-profile/bin "$HOME/Wallpapers/$wallpaper"
fi
