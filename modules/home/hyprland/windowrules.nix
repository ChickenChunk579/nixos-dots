{ ... }:
{
  wayland.displayManager.hyprland.settings.windowrule = [
    "float,class:wlogout"
    "float,class:walker"
  ];
  wayland.windowManager.hyprland.settings.windowrulev2 = [
    "float, initialTitle:^(Steam Input On-screen Keyboard)$"
    "stayfocused, initialTitle:^(Steam Input On-screen Keyboard)$"
    "pin, initialTitle:^(Steam Input On-screen Keyboard)$"
    "abovelock true, initialTitle:^(Steam Input On-screen Keyboard)$" # Critical for visibility over hyprlock
    "noanim, initialTitle:^(Steam Input On-screen Keyboard)$"
    "dimaround, initialTitle:^(Steam Input On-screen Keyboard)$"
  ];


}