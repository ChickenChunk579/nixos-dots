# settings.nix
[
  /*
  {
    layer = "top";
    position = "top";
    mode = "dock";
    reload_style_on_change = true;
    gtk-layer-shell = true;

    padding-top = 6;
    margin-top = 6;

    modules-left = [
      "custom/paddw"
      "hyprland/workspaces"
      "custom/paddw"
      "hyprland/window"
    ];

    modules-center = [
      "custom/left4"
      "memory"
      "custom/paddw"
      "cpu"
      "custom/paddw"
      "clock#time"
      "custom/paddw"
      "clock#date"
      "custom/paddw"
    ];

    modules-right = [
      "custom/left6"
      "pulseaudio"
      "custom/right3"
      "custom/paddw"
      "custom/power"
    ];

    "hyprland/workspaces" = {
      on-scroll-up = "hyprctl dispatch workspace -1";
      on-scroll-down = "hyprctl dispatch workspace +1";
      persistent-workspaces = {
        "1" = [ ];
        "2" = [ ];
        "3" = [ ];
        "4" = [ ];
        "5" = [ ];
      };
    };

    "hyprland/window" = {
      format = " {} ";
      min-length = 5;
      rewrite = {
        "" = "<span foreground='#89b4fa'> </span> Hyprland";
        "~" = "  Terminal";
        "kitty" = "  Terminal";
        "(.*) — Mozilla Firefox" = "<span foreground='#f38ba8'>󰈹 </span> $1";
        "(.*) - Visual Studio Code" = "<span foreground='#89b4fa'>󰨞 </span> $1";
        "Godot" = "<span foreground='#89b4fa'> </span> Godot Engine";
        "(.*)Spotify" = "<span foreground='#a6e3a1'> </span> Spotify";
        "OBS(.*)" = "<span foreground='#a6adc8'>󰐌 </span> OBS Studio";
        "VLC media player" = "<span foreground='#fab387'>󰕼 </span> VLC Media Player";
        "vesktop" = "<span foreground='#89b4fa'> </span> Discord";
        "/" = "  File Manager";
        "Authenticate" = "  Authenticate";
      };
    };

    "custom/ws" = { format = "  "; tooltip = false; min-length = 3; max-length = 3; };
    "custom/cpuinfo" = { exec = "~/.config/waybar/scripts/cpu-temp.sh"; return-type = "json"; interval = 5; };
    memory = { states = { warning = 75; critical = 90; }; format = "  {percentage}% "; tooltip = true; interval = 5; };
    "custom/cpu" = { exec = "~/.config/waybar/scripts/cpu-usage.sh"; return-type = "json"; interval = 5; };
    idle_inhibitor = { format = " "; tooltip = true; tooltip-format-activated = "Presentation Mode"; tooltip-format-deactivated = "Idle Mode"; };
    "clock#time" = { format = " 󱑂 {:%H:%M} "; tooltip-format = "Standard Time: {:%I:%M %p}"; };
    "clock#date" = { format = " 󰨳 {:%m-%d} "; tooltip-format = "<tt>{calendar}</tt>"; calendar = { mode = "month"; mode-mon-col = 6; on-click-right = "mode"; }; };
    "custom/wifi" = { exec = "~/.config/waybar/scripts/wifi-status.sh"; return-type = "json"; on-click = "~/.config/waybar/scripts/wifi-menu.sh"; };
    bluetooth = { format = "󰂰"; format-connected = "󰂱"; tooltip = true; };
    pulseaudio = { format = "  {volume}% "; format-muted = " 󰝟 {volume}% "; };
    "custom/backlight" = { exec = "~/.config/waybar/scripts/brightness-control.sh"; return-type = "json"; };
    battery = { format = "{icon} {capacity}%"; interval = 1; };
    "custom/power" = { format = "   "; tooltip = false; on-click = "~/.config/waybar/scripts/logout-menu.sh"; };
    "custom/paddw".format = " ";

    "cpu".format = "  {usage}% ";
  }*/
  {
    # ---------------------------------------------------
    # Modern Vertical
    # ---------------------------------------------------
    layer = "top";
    position = "left";
    spacing = 0;
    width = 30;
    fixed-center = true;

    margin-top = 2;
    margin-bottom = 2;
    margin-left = 2;
    margin-right = 2;

    # ===================================================
    # MODULE LAYOUT
    # ===================================================
    modules-left = [
      "clock"
      "group/stats"
      "custom/notification"
    ];

    modules-center = [
      "hyprland/workspaces"
    ];

    modules-right = [
      "custom/network"
      "pulseaudio"
      "battery"
      "custom/power"
    ];

    # ===================================================
    # MODULE CONFIGURATION
    # ===================================================

   "hyprland/workspaces" = {
      format = "{name}";
      on-click = "activate";
      sort-by-number = true;
      persistent-workspaces = {
        "1" = [];
        "2" = [];
        "3" = [];
        "4" = [];
        "5" = [];
        # Add more if needed
      };
    };


    "group/stats" = {
      orientation = "vertical";
      modules = [ "cpu" "memory" "temperature" ];
    };

    cpu = {
      format = "\n{usage}";
      interval = 2;
      on-click = "uwsm-app -- kitty --class htop -e htop";
      tooltip-format = "CPU: {usage}%";
      states = {
        critical = 80;
      };
    };

    memory = {
      format = "\n{percentage}";
      interval = 2;
      on-click = "uwsm-app -- kitty --class io_monitor.sh -e $HOME/user_scripts/drives/io_monitor.sh";
      tooltip-format = "Used: {used}GiB";
      states = {
        critical = 80;
      };
    };

    temperature = {
      thermal-zone = 6;
      format = "\n{temperatureC}";
      critical-threshold = 80;
      format-critical = "🔥\n{temperatureC}";
      tooltip-format = "Temp: {temperatureC}°C";
    };

    clock = {
      format = "{:%H\n%M}";
      tooltip-format = "{:%A, %d %B %Y}";
      on-click = "uwsm-app -- gnome-clocks";
      interval = 60;
    };

    "custom/notification" = {
      format = "{icon}";
      return-type = "json";
      exec = "swaync-client -swb";
      on-click = "swaync-client -t -sw";
      on-click-right = "swaync-client -d -sw";
      escape = true;

      format-icons = {
        notification = "<span foreground='red'><sup></sup></span>";
        none = "";
        dnd-notification = "<span foreground='red'><sup></sup></span>";
        dnd-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span>";
        inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        dnd-inhibited-none = "";
      };
    };

    # ---------------------------------------------------
    # UPDATED MODULES WITH NUMBERS
    # ---------------------------------------------------

    pulseaudio = {
      format = "{icon}\n{volume}";
      format-muted = "󰖁\nMute";
      on-click = "uwsm-app -- pavucontrol";
      format-icons = [ "" "" "" ];
      tooltip-format = "Volume: {volume}%";
    };

    battery = {
      format = "{icon}\n{capacity}";
      format-charging = "\n{capacity}";
      format-icons = [
        "󰂎"
        "󰁺"
        "󰁻"
        "󰁼"
        "󰁽"
        "󰁾"
        "󰁿"
        "󰂀"
        "󰂁"
        "󰂂"
        "󰁹"
      ];
      interval = 5;
      tooltip-format = "{timeTo}\nHealth: {health}%";
    };

    "custom/network" = {
      return-type = "json";
      exec = "$HOME/user_scripts/waybar/network/network_meter_calling.sh vertical";
      interval = 1;
      on-click = "uwsm-app -- kitty --class wifitui -e wifitui";
      on-click-right = "nmcli radio wifi on";
      on-click-middle = "nmcli radio wifi off";
    };

    "custom/power" = {
      format = "";
      tooltip = false;
      on-click = "wlogout";
    };
  }
]
