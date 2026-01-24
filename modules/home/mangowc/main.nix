{ config, pkgs, ... }:
{
  wayland.windowManager.mango = {
    enable = true;
    settings = (builtins.readFile ./config.conf);
    autostart_sh = ''
      swww-daemon & sleep 4 && matugen image ~/Wallpapers/current.png
      QML_XHR_ALLOW_FILE_READ=1 qs
      swaync
      swayosd-server
      steam -silent
    '';
  };
}
