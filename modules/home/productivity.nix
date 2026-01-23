# Productivity and office tools
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    localsend
    nautilus
    kdePackages.discover
    obsidian
  ];
}
