# System fonts
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
    material-design-icons
    roboto
  ];
}
