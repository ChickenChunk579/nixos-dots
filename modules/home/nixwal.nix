{ pkgs, ... }:
{
  home.file.".local/bin/nixwal" = {
    text = ''
      #!/usr/bin/env bash
      set -e

      WALLPAPER="$1"
      CURRENT="$HOME/Wallpapers/current.txt"
      SYMLINK="$HOME/wallpaper.png"

      if [ -z "$WALLPAPER" ]; then
        echo "Usage: nixwal <wallpaper>"
        exit 1
      fi

      WALLPAPER="$(realpath "$WALLPAPER")"

      mkdir -p "$(dirname "$CURRENT")"
      echo "$WALLPAPER" > "$CURRENT"

      # Update symlink to current wallpaper
      ln -sf "$WALLPAPER" "$SYMLINK"

      #pywal-spicetify

      ${pkgs.pywal}/bin/wal -i "$WALLPAPER" -n -s -t
      ${pkgs.swww}/bin/swww img "$WALLPAPER" \
        --transition-type grow \
        --transition-fps 90
      
      #pywal-spicetify Dribbblish

      pkill -SIGUSR2 waybar || true
      pywalfox update || true
      stty sane || true

      pkill swaync || true
      swaync & disown

      until [ -f "$HOME/.cache/wal/colors" ]; do
        sleep 0.1
      done

      (cd "$HOME/.local/bin" && ./pywal-obsidian "$HOME/Obsidian/")


    '';
    executable = true;
  };
  /*

  home.file.".local/bin/nixwald" = {
    text = ''
      #!/usr/bin/env bash
      set -e

      CURRENT="$HOME/Wallpapers/current.txt"

      [ -f "$CURRENT" ] || exit 0

      WALLPAPER="$(cat "$CURRENT")"

      [ -f "$WALLPAPER" ] || exit 0

      ${pkgs.pywal}/bin/wal -i "$WALLPAPER" -n -s -t
      ${pkgs.swww}/bin/swww img "$WALLPAPER" \
        --transition-type grow \
        --transition-fps 90

      pkill -SIGUSR2 waybar || true
      pywalfox update || true

      pkill swaync || true
      swaync & disown
    '';
    executable = true;
  };

  systemd.user.paths.nixwald = {
    Unit = {
      Description = "Watch wallpaper file for changes";
    };

    Path = {
      PathChanged = "%h/Wallpapers/current.txt";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.nixwald = {
    Unit = {
      Description = "Apply wallpaper from current.txt";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "%h/.local/bin/nixwald";
    };
  };
  */
}