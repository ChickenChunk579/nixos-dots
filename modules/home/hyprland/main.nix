{ ... }:
{
  imports = [
    ./startup.nix
    ./input.nix
    ./monitors.nix
    ./binds.nix
    ./appearance.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
    };
  };
}
