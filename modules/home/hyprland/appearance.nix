{ ... }:
{
  home.file.".config/wal/templates/colors-hyprland".text = ''
    $foregroundCol = 0xff{foreground.strip}
    $backgroundCol = 0xff{background.strip}
    $color0 = 0xff{color0.strip}
    $color1 = 0xff{color1.strip}
    $color2 = 0xff{color2.strip}
    $color3 = 0xff{color3.strip}
    $color4 = 0xff{color4.strip}
    $color5 = 0xff{color5.strip}
    $color6 = 0xff{color6.strip}
    $color7 = 0xff{color7.strip}
    $color8 = 0xff{color8.strip}
    $color9 = 0xff{color9.strip}
    $color10 = 0xff{color10.strip}
    $color11 = 0xff{color11.strip}
    $color12 = 0xff{color12.strip}
    $color13 = 0xff{color13.strip}
    $color14 = 0xff{color14.strip}
    $color15 = 0xff{color15.strip}
  '';
  wayland.windowManager.hyprland = {
    settings = {
      source = [
        "~/.cache/wal/colors-hyprland"
      ];
      general = {
        layout = "dwindle";

        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;

        "col.inactive_border" = "$color0";
        "col.active_border" = "$color1";

        resize_on_border = true;
      };

      decoration = {
        rounding = 10;
        rounding_power = 2;

        # Change transparency of focused and unfocused windows
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        # https://wiki.hypr.land/Configuring/Variables/#blur
        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "fluid, 0.25, 1, 0, 1"
          "snap, 0.5, 0.9, 0.1, 1.05"
          "menu_decel, 0.1, 1, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windowsIn, 1, 7, overshot, popin 80%"
          "windowsOut, 1, 5, snap, popin 80%"
          "windowsMove, 1, 7, overshot, slide"
          "border, 1, 2, liner"
          "borderangle, 1, 40, liner, once"
          "fade, 1, 5, fluid"
          "layersIn, 1, 6, overshot, popin 70%"
          "layersOut, 0, 0, menu_decel, slide"
          "fadeLayersIn, 1, 5, menu_decel"
          "fadeLayersOut, 1, 4, menu_decel"
          "workspaces, 1, 8, overshot, slidevert"
          "specialWorkspace, 1, 8, overshot, slide"
        ];

      };
    };
  };
}
