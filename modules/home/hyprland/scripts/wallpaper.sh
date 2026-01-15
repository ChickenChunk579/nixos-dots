#!/usr/bin/env bash

# Start in the Wallpapers directory
current_dir="$HOME/Wallpapers"

while true; do
    dirs=()
    files=()

    # Collect directories and image files separately
    for item in "$current_dir"/*; do
        if [[ -d "$item" ]]; then
            dirs+=("$(basename "$item")/")
        elif [[ "$item" =~ \.(jpg|jpeg|png|bmp|gif|webp)$ ]]; then
            files+=("$(basename "$item")")
        fi
    done

    # Build menu: Random first, then directories, then files
    choices=("Random" "${dirs[@]}" "${files[@]}")

    # Pick an item
    selection=$(printf '%s\n' "${choices[@]}" | walker --dmenu)

    # Exit if nothing selected
    [[ -z "$selection" ]] && exit 0

    # Random wallpaper from current directory
    if [[ "$selection" == "Random" ]]; then
        (( ${#files[@]} == 0 )) && continue
        random_file="${files[RANDOM % ${#files[@]}]}"
        ~/.local/bin/nixwal "$current_dir/$random_file"
        exit 0
    fi

    # Directory navigation
    if [[ "$selection" == */ ]]; then
        current_dir="$current_dir/${selection%/}"
        continue
    else
        matugen image "$current_dir/$selection" -m dark
        exit 0
    fi
done
