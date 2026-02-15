{ pkgs, ... }:
{
  home.packages = with pkgs: {
    azahar
    melonds
    cemu
    mgba
    nestopia-ue
    skyemu
  };
}
