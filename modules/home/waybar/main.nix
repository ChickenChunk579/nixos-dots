# main.nix
let
  waybarStyle = import ./style.nix;
  waybarConfig = import ./settings.nix;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = waybarStyle.style;

    settings = waybarConfig;
  };
}
