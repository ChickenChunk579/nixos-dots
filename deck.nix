{ config, lib, pkgs, hyprland, walker, jovian, ... }:
{
  jovian.steam.enable = true;
  jovian.steam.autoStart = true;
  jovian.steam.desktopSession = "hyprland-custom";
}