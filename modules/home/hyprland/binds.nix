{ pkgs, ... }:
{
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    libnotify
    hyprshade
    jq
    playerctl
  ];
  home.file.".config/hypr/scripts" = {
    source = ./scripts;
    recursive = true;
  };
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind = [
      "$mod, Return, exec, kitty"
      "$mod, Q, killactive"
      "$mod, Space, exec, wofi --show drun"
      "$mod SHIFT, P, exec, qs ipc call shell powerMenu"
      "$mod CTRL, L, exec, qs ipc call shell lock"
      "$mod SHIFT, C, exec, qs ipc call shell controlPanel"
      "$mod SHIFT, Space, togglefloating"
      "$mod SHIFT, S, exec, sh -c \"grim -g \\\"$(slurp)\\\" - | wl-copy && notify-send 'Screenshot copied'\""
      "$mod CTRL, S, exec, sh -c \"grim -g \\\"$(slurp)\\\" $HOME/screenshot.png && notify-send 'Screenshot saved'\""
      "$mod SHIFT, F, fullscreen"
      
      "$mod, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"
      "$mod, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"


      "$mod SHIFT, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor 1"
      "$mod SHIFT, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor 1"
      "$mod SHIFT, minus, exec, hyprctl -q keyword cursor:zoom_factor 1"
      "$mod SHIFT, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor 1"
      "$mod SHIFT, 0, exec, hyprctl -q keyword cursor:zoom_factor 1"
      "$mod SHIFT, W, exec, bash ~/.config/hypr/scripts/wallpaper.sh"

      ",Home , exec, /home/rhys/nix/menu.sh"
    ]
    ++ (
      # workspaces
      # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
      builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = i + 1;
          in
          [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        ) 9
      )
    );
    bindm = [
      "$mod, mouse:272, movewindow"
    ];
    binde = [
      "$mod, equal, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"
      "$mod, minus, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"
      "$mod, KP_ADD, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"
      "$mod, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"
    ];
    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
    bindel = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && swayosd-client --output-volume=raise"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && swayosd-client --output-volume=lower"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && swayosd-client --output-volume=mute-toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ",XF86PowerOff, exec, systemctl suspend"
    ];
  };
}
