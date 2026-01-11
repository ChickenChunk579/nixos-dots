#!/usr/bin/env bash

# Get a list of available shaders and add "None" to the top
SHADERS=$(echo -e "None\n$(hyprshade ls)" | walker --dmenu)

# Handle the selection
if [[ "$SHADERS" == "None" ]]; then
    hyprshade off
elif [[ -n "$SHADERS" ]]; then
    # hyprshade ls sometimes adds an asterisk (*) next to the active shader;
    # we strip it to ensure the command works correctly.
    CLEAN_SHADER=$(echo "$SHADERS" | sed 's/\*//' | xargs)
    hyprshade on "$CLEAN_SHADER"
fi