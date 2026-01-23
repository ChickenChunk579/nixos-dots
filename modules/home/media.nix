# Media and content creation tools
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gimp
    obs-studio
    mpv
    geeqie
  ];
}
