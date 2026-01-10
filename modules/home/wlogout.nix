{ ... }:
{
  home.file.".config/wlogout/icons" = {
    source = ./icons;
    recursive = true;
  };

  programs.wlogout = {
    enable = true;
    layout = [
      {
    "label" = "shutdown";
    "action" = "systemctl poweroff";
    "text" = "Shutdown";
    "keybind" = "s";
}
{
    "label" = "reboot";
    "action" = "systemctl reboot";
    "text" = "Reboot";
    "keybind" = "r";
}
{
    "label" = "logout";
    "action" = "loginctl kill-session $XDG_SESSION_ID";
    "text" = "Logout";
    "keybind" = "e";
}
{
    "label" = "sleep";
    "action" = "loginctl lock-session && systemctl suspend";
    "text" = "Sleep";
    "keybind" = "h";
}
{
    "label" = "lock";
    "action" = "loginctl lock-session";
    "text" = "Lock";
    "keybind" = "l";
}
    ];
    style = ''
            @import url("file:///home/rhys/.cache/wal/colors-waybar.css");
            @define-color window_bg_color    @background;
            @define-color accent_bg_color    @color1;
            @define-color theme_fg_color     @foreground;
            @define-color error_bg_color     @color1;   /* red-ish error background */
            @define-color error_fg_color     @foreground;
            @define-color inactive_bg_color  @color0;
            @define-color inactive_fg_color  @color8;
            @define-color active_bg_color    @color1;
            @define-color active_fg_color    @foreground;
            @define-color warning_bg_color   @color3;
            @define-color warning_fg_color   @foreground;
            @define-color info_bg_color      @color2;
            @define-color info_fg_color      @foreground;
            @define-color success_bg_color   @color6;
            @define-color success_fg_color   @foreground;
            @define-color highlight_color    @color7;
            
            /***
       *    ┓ ┏┓ ┏┓┏┓┏┓┳┳┏┳┓
       *    ┃┃┃┃ ┃┃┃┓┃┃┃┃ ┃ 
       *    ┗┻┛┗┛┗┛┗┛┗┛┗┛ ┻ 
       *                    
       */


      /* wallust-wlogout */


      window {
          font-family: GeistMono Nerd Font Propo;
          font-size: 16pt;
          color:  @foreground; /* text */
          background-color: @surface-alpha;

      } 

      button {
          background-repeat: no-repeat;
          background-position: center;
          background-size: 20%;
          background-color: transparent;
          animation: gradient_f 20s ease-in infinite;
          transition: all 0.3s ease-in;
          box-shadow: 0 0 10px 2px transparent;
          border-radius: 36px;
          margin: 10px;
      }


      button:focus {
          box-shadow: none;
          outline-style: none;
          background-size : 20%;
      }

      button:hover {
          background-size: 50%;
          outline-style: none;
          box-shadow: 0 0 10px 3px rgba(0,0,0,.4);
          background-color: @primary;
          color: transparent;
          transition: all 0.3s cubic-bezier(.55, 0.0, .28, 1.682), box-shadow 0.5s ease-in;
      }

      #shutdown {
          background-image: image(url("./icons/power.png"));
      }
      #shutdown:hover {
        background-image: image(url("./icons/power-hover.png"));
      }

      #logout {
          background-image: image(url("./icons/logout.png"));

      }
      #logout:hover {
        background-image: image(url("./icons/logout-hover.png"));
      }

      #reboot {
          background-image: image(url("./icons/restart.png"));
      }
      #reboot:hover {
        background-image: image(url("./icons/restart-hover.png"));
      }

      #lock {
          background-image: image(url("./icons/lock.png"));
      }
      #lock:hover {
        background-image: image(url("./icons/lock-hover.png"));
      }

      #sleep {
          background-image: image(url("./icons/hibernate.png"));
      }
      #sleep:hover {
        background-image: image(url("./icons/hibernate-hover.png"));
      }
    '';
  };
}
