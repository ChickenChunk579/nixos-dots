# Gaming and entertainment
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    godot
    osu-lazer-bin
    prismlauncher
    bottles
  ];
}
