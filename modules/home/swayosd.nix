{ pkgs, ... }:
{
  home.file.".config/swayosd/style.css".text = ''
    @import url("file:///home/rhys/.cache/wal/colors-waybar.css");

    * {
      font-family: "RobotoMono Nerd Font";
      color: @color1;
      foreground-color: @color1;
    }

    window#osd {
      border-radius: 4px;
      border: 2px solid @color1;
      background: @background;
    }

    window#osd #container {
      margin: 16px;
    }

    window#osd image,
    window#osd label {
      color: @color1;
      opacity: 1.0;
    }

    window#osd progressbar:disabled,
    window#osd image:disabled {
      opacity: 1.0;
    }

    window#osd progressbar {
      min-height: 6px;
      border-radius: 999px;
      background: transparent;
      border: none;
    }

    window#osd trough {
      min-height: inherit;
      border-radius: inherit;
      border: none;
      background: alpha(@color1, 1.0);
    }

    window#osd progress {
      min-height: inherit;
      border-radius: inherit;
      border: none;
      background: @color1;
    }


  '';
  services.swayosd = {
    enable = true;
    stylePath = "/home/rhys/.config/swayosd/style.css";
  };
}