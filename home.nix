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
      vscode
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
      classicube
      osu-lazer-bin
      mcpelauncher-client
      ghidra-bin
    ];
    username = "rhys";
    homeDirectory = "/home/rhys";

    stateVersion = "25.11";
  };

  services.udiskie = {
    enable = true;
    settings = {
        # workaround for
        # https://github.com/nix-community/home-manager/issues/632
        program_options = {
            # replace with your favorite file manager
            
        };
    };
  };

  #programs.sm64ex = {
  #  enable = true;
  #  baserom = "/home/rhys/roms/baserom.us.z64";
  #  region = "us";
  #};
}
