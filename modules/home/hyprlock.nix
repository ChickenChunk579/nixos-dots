{ ... }:
{
    programs.hyprlock.enable = true;
  programs.hyprlock.settings = {
    source = [
      "~/.cache/wal/colors-hyprland"
    ];

    general = {
      hide_cursor = true;
      ignore_empty_input = true;
      no_fade_in = false;
      grace = 0;
      disable_loading_bar = false;
    };

    animations = {
      enabled = true;

      fade_in = {
        duration = 300;
        bezier = "easeOutQuint";
      };

      fade_out = {
        duration = 300;
        bezier = "easeOutQuint";
      };
    };

    ################################
    # Background
    ################################
    background = [
      {
        monitor = "";
        path = "/home/rhys/wallpaper.png";
        blur_passes = 2;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      }
    ];

    ################################
    # Input Field
    ################################
    input-field = [
      {
        monitor = "";
        size = "250, 60";
        position = "0, -225";

        halign = "center";
        valign = "center";

        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;

        outer_color = "rgba(0,0,0,0)";
        inner_color = "$color8"; # soft translucent blue-gray
        font_color = "$foreground";

        fade_on_empty = false;
        hide_input = false;

        font_family = "RobotoMono Nerd Font";
        placeholder_text = "<i>Enter Pass</i>";
      }
    ];

    ################################
    # Time
    ################################
    label = [
      {
        monitor = "";
        text = "cmd[update:1000] echo \"<span>$(date +\"%H:%M\")</span>\"\"";
        color = "$foreground";
        font_size = 130;
        font_family = "RobotoMono Nerd Font";
        position = "0, 240";
        halign = "center";
        valign = "center";
      }

      ################################
      # Day / Date
      ################################
      {
        monitor = "";
        text = "cmd[update:1000] echo \"$(date +\"%A, %d %B\")\"\"";
        color = "$foreground";
        font_size = 30;
        font_family = "RobotoMono Nerd Font";
        position = "0, 105";
        halign = "center";
        valign = "center";
      }

      ################################
      # User Greeting
      ################################
      {
        monitor = "";
        text = "Hi, $USER";
        color = "$foreground";
        font_size = 25;
        font_family = "RobotoMono Nerd Font";
        position = "0, -130";
        halign = "center";
        valign = "center";
      }
    ];

    ################################
    # Profile Image
    ################################
    image = [
      {
        monitor = "";
        path = "/home/rhys/.config/hypr/rhys.png";
        size = 120;
        rounding = -1;
        border_size = 0;
        border_color = "$foreground";
        position = "0, -20";
        halign = "center";
        valign = "center";
      }
    ];
  };
}