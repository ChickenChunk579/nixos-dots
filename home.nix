{ libs, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      fastfetch
      kitty
      wofi
      waybar
      hyprpaper
      firefox
      clang
      starship
      quickshell
      jq
      pavucontrol
      vscodium
      rose-pine-kvantum
      libsForQt5.qt5ct
      kdePackages.qt6ct
      rose-pine-gtk-theme
      kdePackages.qtdeclarative
      kdePackages.qtstyleplugin-kvantum
      gnome-tweaks
      gh
      nixfmt
    ];
    
    username = "rhys";
    homeDirectory = "/home/rhys";

    stateVersion = "25.11";
  };
}
