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
      WALLPAPER="$1"

      if [ -z "$WALLPAPER" ]; then
        echo "Usage: nixwal <wallpaper>"
        exit 1
      fi

      ${pkgs.pywal}/bin/wal -i "$WALLPAPER" -n -s -t
      ${pkgs.swww}/bin/swww img $WALLPAPER --transition-type grow --transition-fps 90
      pkill -SIGUSR2 waybar
      pywalfox update
      stty sane

      pkill swaync
      swaync & disown
    '';
    executable = true;
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
