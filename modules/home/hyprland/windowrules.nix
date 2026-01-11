{ ... }:
{
  wayland.displayManager.hyprland.settings.windowrule = [
    "float,class:wlogout"
    "float,class:walker"
  ];
  wayland.windowManager.hyprland.settings.windowrulev2 = [
    "float,title:(swayosd-server)"
    "float, initialTitle:^(Steam Input On-screen Keyboard)$"
    "stayfocused, initialTitle:^(Steam Input On-screen Keyboard)$"
    "pin, initialTitle:^(Steam Input On-screen Keyboard)$"
  ];
}