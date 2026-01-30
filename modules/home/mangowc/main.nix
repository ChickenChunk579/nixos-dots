{ config, pkgs, ... }:
{
  wayland.windowManager.mango = {
    enable = true;
    systemd = false;
    settings = ''
      bind=Super,Return,kitty
      bind=Super,Space,wofi --show drun
    '';
    autostart_sh = ''
      swww-daemon & sleep 4 && matugen image ~/Wallpapers/current.png
      QML_XHR_ALLOW_FILE_READ=1 qs
      swaync
      swayosd-server
      steam -silent
    '';
  };
}
