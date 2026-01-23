# Utilities and miscellaneous
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cloc
    blanket
    pywal
    pywalfox-native
    github-cli
    lm_sensors
  ];

  services.syncthing.enable = true;
}
