{ pkgs, glacier, ... }:

let
  isHyprland = glacier.programs.windowManager == "hyprland";

  scriptBody = if isHyprland then ''
    ROOT_RESULT=$(echo -e \
      "Terminal\nLauncher\nWorkspace Left\nWorkspace Right\nScreenshot (Copy)\nChange Wallpaper\nChange Shaders\nKill Active\nLock\nFloat\nPower" \
      | wofi --show dmenu)

    [[ "$ROOT_RESULT" == "Terminal" ]] && hyprctl dispatch exec "kitty"
    [[ "$ROOT_RESULT" == "Launcher" ]] && hyprctl dispatch exec "wofi --show drun"
    [[ "$ROOT_RESULT" == "Workspace Left" ]] && hyprctl dispatch workspace r-1
    [[ "$ROOT_RESULT" == "Workspace Right" ]] && hyprctl dispatch workspace r+1
    [[ "$ROOT_RESULT" == "Change Wallpaper" ]] && ~/.config/hypr/scripts/wallpaper.sh
    [[ "$ROOT_RESULT" == "Change Shaders" ]] && wofi-shaders
    [[ "$ROOT_RESULT" == "Screenshot (Copy)" ]] && grim -g "$(slurp)" - | wl-copy && notify-send 'Screenshot copied'
    [[ "$ROOT_RESULT" == "Lock" ]] && hyprlock & disown
    [[ "$ROOT_RESULT" == "Float" ]] && hyprctl dispatch togglefloating
    [[ "$ROOT_RESULT" == "Kill Active" ]] && hyprctl dispatch killactive

    if [[ "$ROOT_RESULT" == "Power" ]]; then
      POWER_RESULT=$(echo -e "Shutdown\nReboot\nReturn to Steam" | wofi --show dmenu)
      [[ "$POWER_RESULT" == "Shutdown" ]] && shutdown now
      [[ "$POWER_RESULT" == "Reboot" ]] && reboot
      [[ "$POWER_RESULT" == "Return to Steam" ]] && hyprctl dispatch exit
    fi
  '' else ''
    # MangoWC Version using mmsg
    ROOT_RESULT=$(echo -e \
      "Terminal\nLauncher\nTag Left\nTag Right\nScreenshot (Copy)\nChange Wallpaper\nKill Active\nLock\nFloat\nPower" \
      | wofi --show dmenu)

    [[ "$ROOT_RESULT" == "Terminal" ]] && kitty & disown
    [[ "$ROOT_RESULT" == "Launcher" ]] && wofi --show drun --cache-file /dev/null & disown
    [[ "$ROOT_RESULT" == "Tag Left" ]] && mmsg -d "viewprevtag"
    [[ "$ROOT_RESULT" == "Tag Right" ]] && mmsg -d "viewnexttag"
    [[ "$ROOT_RESULT" == "Change Wallpaper" ]] && ~/.config/mango/scripts/wallpaper.sh
    [[ "$ROOT_RESULT" == "Screenshot (Copy)" ]] && grim -g "$(slurp)" - | wl-copy && notify-send 'Screenshot copied'
    [[ "$ROOT_RESULT" == "Lock" ]] && hyprlock & disown
    [[ "$ROOT_RESULT" == "Float" ]] && mmsg -d "togglefloating"
    [[ "$ROOT_RESULT" == "Kill Active" ]] && mmsg -d "killclient"

    if [[ "$ROOT_RESULT" == "Power" ]]; then
      POWER_RESULT=$(echo -e "Shutdown\nReboot\nReturn to Steam" | wofi --show dmenu)
      [[ "$POWER_RESULT" == "Shutdown" ]] && shutdown now
      [[ "$POWER_RESULT" == "Reboot" ]] && reboot
      [[ "$POWER_RESULT" == "Return to Steam" ]] && mmsg -q
    fi
  '';
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "deck-menu" ''
      #!/usr/bin/env bash
      ${scriptBody}
    '')

    (pkgs.writeShellScriptBin "wofi-shaders" ''
      #!/usr/bin/env bash

      SHADERS=$(echo -e "None\n$(hyprshade ls)" | wofi --show dmenu)

      if [[ "$SHADERS" == "None" ]]; then
        hyprshade off
      elif [[ -n "$SHADERS" ]]; then
        CLEAN_SHADER=$(echo "$SHADERS" | sed 's/\*//' | xargs)
        hyprshade on "$CLEAN_SHADER"
      fi
    '')
    (pkgs.writeShellScriptBin "wofi-wallpapers" ''
      #!/usr/bin/env bash

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

        # Build menu and get selection
        selection=$(
          {
            echo "Random"
            printf '%s\n' "''${dirs[@]}"
            for file in "''${files[@]}"; do
              printf '%s\0icon\x1f%s\n' "$file" "$current_dir/$file"
            done
          } | wofi --show dmenu --allow-images
        )

        # Exit if nothing selected (including ESC)
        [[ -z "$selection" ]] && exit 0

        # Random wallpaper from current directory
        if [[ "$selection" == "Random" ]]; then
          (( ''${#files[@]} == 0 )) && continue
          random_file="''${files[RANDOM % ''${#files[@]}]}"
          ~/.local/bin/nixwal "$current_dir/$random_file"
          exit 0
        fi

        # Directory navigation
        if [[ "$selection" == */ ]]; then
          current_dir="$current_dir/''${selection%/}"
          continue
        else
          matugen image "$current_dir/$selection" -m dark
          exit 0
        fi
      done
    '')

  ];
}
