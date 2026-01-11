# style.nix
{
  /*
  style = ''
    @import url("file:///home/rhys/.cache/wal/colors-waybar.css");

    * {
      font-family: "RobotoMono Nerd Font";
      font-weight: bold;
      font-size: 16px;
      background: transparent;
      text-align: center;
      border-radius: 0px;
      box-sizing: border-box;
    }

    window#waybar {
      background: transparent;
    }

    #workspaces { background: @background; border-radius: 8px; }
    #workspaces button { color: @foreground; }
    #workspaces button.active { background: @background; color: @color1; }
    #window { background: @background; color: @foreground; border-radius: 8px; }
    #memory { background: @background; color: @foreground; border-radius: 8px; }
    #clock { background: @background; color: @foreground; border-radius: 8px; }
    #pulseaudio { background: @background; color: @foreground; border-radius: 8px; }
    #cpu { background: @background; color: @foreground; border-radius: 8px; }

    #custom-power {background: @background; color: @foreground; border-radius: 8px;}
    #pulseaudio {background: transparent;}
  '';*/
  style = ''
    @import url("file:///home/rhys/.cache/wal/colors-waybar.css");

    /* --------------------------------------------------
      GLOBAL FONT & WAYBAR SETTINGS
    -------------------------------------------------- */
    * {
        font-family: "RobotoMono Nerd Font", "Noto Sans", sans-serif;
        font-size: 13px;
        font-weight: bold;
        min-height: 0;;
        border: none;
        border-radius: 8px;
    }

    window#waybar {
        background: @background;
        color: @foreground;
        border: 2px solid @color1
    }

    /* --------------------------------------------------
      UNIFIED CAPSULE STYLE
    -------------------------------------------------- */
    #clock,
    #custom-notification,
    #workspaces,
    #group-stats,
    #pulseaudio,
    #battery,
    #custom-network {
        background-color: @color0; /* surface container -> dark background */
        color: @foreground;        /* on_surface */
        border-radius: 10px;
        margin: 3px 1px;
        padding: 6px 0;
        box-shadow: 0 2px 3px rgba(0,0,0,0.2);
    }

    /* --- TOP SECTION --- */
    #clock {
        background-color: @color3; /* primary container -> gold/yellow accent */
        color: @color0;            /* on_primary_container -> dark text */
        font-size: 10px;
        padding-bottom: 8px;
    }

    #group-stats {
        background-color: @color2; /* surface_container_low -> darker accent */
        padding: 8px 0;
    }

    #cpu, #memory, #temperature {
        background: transparent;
        box-shadow: none;
        margin: 4px 0;
        padding: 0;
        font-size: 10px;
        color: @color15; /* on_surface_variant -> light gray */
        text-shadow: 1px 1px 2px rgba(0,0,0,1.0);
    }

    /* Critical state coloring */
    #cpu.critical, 
    #memory.critical, 
    #temperature.critical {
        color: @color1; /* error -> dark orange/red */
    }

    #custom-notification {
        color: @color15;
    }

    /* --- CENTER SECTION --- */
    #workspaces {
        background-color: transparent; /* surface_container_high */
        padding: 2px 0;
        border: 2px solid @color1;
    }

    #workspaces button {
        padding: 2px 0;
        margin: 1px 2;
        border-radius: 9px;
        color: @foreground;          /* text color */
        background-color: transparent; /* keep background transparent */
        transition: all 0.2s ease;
    }

    #workspaces button.active {
        background-color: @color1; /* active bg */
        color: @color0;            /* active text */
        border: 2px solid @color1; /* active border matches bg */
    }

    #workspaces button.urgent {
        background-color: @color1; /* error */
        color: @color0;            /* text */
        border: 2px solid @color1; /* urgent border matches bg */
    }

    #workspaces button:hover {
        background-color: @color3; /* hover bg */
        border: 2px solid @color3; /* hover border matches bg */
    }


    /* --- BOTTOM SECTION --- */
    #custom-network {
        font-size: 10px;
        padding: 8px 0;
    }

    #pulseaudio, #battery {
        font-size: 10px;
        padding: 8px 0;
    }

    #battery.charging { color: @color11; }  /* tertiary */
    #battery.warning { color: @color1; }    /* error */

    #custom-power {
        background-color: transparent;
        box-shadow: none;
        color: @color1; /* error */
        font-size: 16px;
        margin-top: 6px;
        margin-bottom: 2px;
        padding: 0;
    }

    #custom-power:hover {
        color: @color11; /* error_container -> goldish accent */
    }

    #pulseaudio,
    #battery,
    #custom-network,
    #custom-notification {
        padding: 4px 0;
        margin: 2px 1px;
    }




  '';
}
