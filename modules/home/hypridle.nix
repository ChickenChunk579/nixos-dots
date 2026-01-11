{ pkgs, ... }:
{
  services.hypridle.enable = true;
  services.hypridle.settings = {
    lockCommand = "${pkgs.hyprlock}/bin/hyprlock";
  };
}