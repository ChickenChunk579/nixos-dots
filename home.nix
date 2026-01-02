{ libs, pkgs, inputs, ... }:
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
      python3
      meson
      ninja
      glm
      libpulseaudio
      pkg-config
      cmake
      steamtinkerlaunch
      xorg.xdpyinfo
      cage
      wlr-randr
      xfce.thunar
      p7zip
      xarchiver
      kdePackages.discover
      wine
      unarc
      swayosd
      clang-tools
      udev
    ];
    username = "rhys";
    homeDirectory = "/home/rhys";

    stateVersion = "25.11";
  };
}
