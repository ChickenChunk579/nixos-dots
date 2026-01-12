#!/usr/bin/env bash

# Start in the Wallpapers directory
current_dir="$HOME/Wallpapers"

while true; do
    # List files and directories in current_dir
    # Only show files with image extensions
    choices=()
    for item in "$current_dir"/*; do
        if [[ -d "$item" ]]; then
            choices+=("$(basename "$item")/")
        elif [[ "$item" =~ \.(jpg|jpeg|png|bmp|gif|webp)$ ]]; then
            choices+=("$(basename "$item")")
        fi
    done

    # Use walker (or dmenu) to pick an item
    selection=$(printf '%s\n' "${choices[@]}" | walker --dmenu)

    # Exit if nothing selected
    [[ -z "$selection" ]] && exit 0

    # Check if selection is a directory
    if [[ "$selection" == */ ]]; then
        # Navigate into the selected directory
        current_dir="$current_dir/${selection%/}"
        continue
    else
        # Set the wallpaper and exit
        ~/.local/bin/nixwal "$current_dir/$selection"
        exit 0
    fi
done
