{ pkgs, ... }:
{
  home.packages = with pkgs; [
    azahar
    melonDS
    cemu
    mgba
    nestopia-ue
    skyemu
    dolphin-emu
  ];
}
