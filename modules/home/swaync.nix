{ pkgs, ... }:
{
  home.file.".config/wal/templates/colors-mako".text = ''
    background-color=#{background.strip}
    border-color=#{foreground.strip}
  '';
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
    };
    style = ''
      @import url("file:///home/rhys/.cache/wal/colors-waybar.css");

      * {
        font-family: "RobotoMono Nerd Font";
        color: @color1;
      }

      .notification-row {
        outline: none;
      }
      
      .notification {
        border-radius: 12px;
        margin: 6px 12px;
        border: 2px solid @color1;
        padding: 0;
        background: @background;
      }
    '';

  };
}