{ pkgs, config, isDeck, ... }:
{
  home.packages = with pkgs; [
    swww
  ];
  wayland.windowManager.hyprland.settings.exec-once = [
    "swww-daemon"
    "pkill waybar && waybar"
    "hyprctl setcursor material_light_cursors 32"
    "dbus-update-activation-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP=Hyprland SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME"
    "swaync"
    "swayosd"
  ]
  ++ pkgs.lib.optional isDeck "steam -silent";
}
