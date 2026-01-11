{
  pkgs,
  walker,
  hyprland,
  waybar,
  ...
}:
{
  imports = [
    walker.homeManagerModules.default
    ./hyprland/main.nix
    ./walker.nix
    ./waybar/main.nix
    ./hyprshade/main.nix
    ./wlogout.nix
    ./swaync.nix
    ./swayosd.nix
  ];
  home = {
    packages = with pkgs; [
      fastfetch
      starship
      gnumake
      localsend
      nixfmt
      pywal
      python3
      git
      pywalfox-native
      nautilus
      kdePackages.discover
      material-cursors
      godot
      cloc
      blanket
      obs-studio
      github-cli
      geeqie
    ];
    username = "rhys";
    homeDirectory = "/home/rhys";

    stateVersion = "25.11";

    sessionVariables = {
      EDITOR = "nano";
      NIXOS_OZONE_WL = "1";
    };
  };

  home.file.".bashrc".text = ''
    eval -- "$(/etc/profiles/per-user/rhys/bin/starship init bash --print-full-init)"
  '';

  home.file.".local/bin/nixwal" = {
    text = ''
      #!/usr/bin/env bash
      set -e

      WALLPAPER="$1"
      CURRENT="$HOME/Wallpapers/current.txt"

      if [ -z "$WALLPAPER" ]; then
        echo "Usage: nixwal <wallpaper>"
        exit 1
      fi

      WALLPAPER="$(realpath "$WALLPAPER")"

      mkdir -p "$(dirname "$CURRENT")"
      echo "$WALLPAPER" > "$CURRENT"

      ${pkgs.pywal}/bin/wal -i "$WALLPAPER" -n -s -t
      ${pkgs.swww}/bin/swww img "$WALLPAPER" \
        --transition-type grow \
        --transition-fps 90

      pkill -SIGUSR2 waybar || true
      pywalfox update || true
      stty sane || true

      pkill swaync || true
      swaync & disown
    '';
    executable = true;
  };

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




  home.file.".steam/steam/.cef-enable-remote-debugging".text = "1";

  home.sessionPath = [ "~/.local/bin" ];

  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = 0.8;
      blur = true;
      confirm_os_window_close = 0;
    };
    extraConfig = ''
      include ~/.cache/wal/colors-kitty.conf
    '';
  };
  programs.firefox.enable = true;
  programs.neovim.enable = true;
  programs.vscode.enable = true;

  services.syncthing.enable = true;
}
