#!/run/current-system/sw/bin/bash
ROOT_RESULT=$(echo -e "Terminal\nLauncher\nWorkspace Left\nWorkspace Right\nScreenshot (Copy)\nChange Wallpaper\nChange Shaders\nKill Active\nLock\nPower" | walker --dmenu)
if [[ "$ROOT_RESULT" == "Terminal" ]]; then
  hyprctl dispatch exec "kitty"
fi
if [[ "$ROOT_RESULT" == "Launcher" ]]; then
  hyprctl dispatch exec "walker"
fi
if [[ "$ROOT_RESULT" == "Workspace Left" ]]; then
  hyprctl dispatch workspace r-1
fi
if [[ "$ROOT_RESULT" == "Workspace Right" ]]; then
  hyprctl dispatch workspace r+1
fi
if [[ "$ROOT_RESULT" == "Change Wallpaper" ]]; then
  ~/.config/hypr/scripts/wallpaper.sh
fi
if [[ "$ROOT_RESULT" == "Change Shaders" ]]; then
  ~/nix/shade.sh
fi
if [[ "$ROOT_RESULT" == "Screenshot (Copy)" ]]; then
  grim -g "$(slurp)" - | wl-copy && notify-send 'Screenshot copied'
fi
if [[ "$ROOT_RESULT" == "Lock" ]]; then
  hyprlock & disown
  
fi
if [[ "$ROOT_RESULT" == "Kill Active" ]]; then
  hyprctl dispatch killactive
fi
if [[ "$ROOT_RESULT" == "Power" ]]; then
  POWER_RESULT=$(echo -e "Shutdown\nReboot\nReturn to Steam" | walker --dmenu)

  if [[ "$POWER_RESULT" == "Shutdown" ]]; then
    shutdown now
  fi

  if [[ "$POWER_RESULT" == "Reboot" ]]; then
    reboot
  fi

  if [[ "$POWER_RESULT" == "Return to Steam" ]]; then
    hyprctl dispatch exit
  fi
fi
