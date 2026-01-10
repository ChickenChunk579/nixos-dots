#!/run/current-system/sw/bin/bash
ROOT_RESULT=$(echo -e "Terminal\nLauncher\nWorkspace Left\nWorkspace Right\nKill Active\nPower" | wofi --show dmenu --cache-file /dev/null)

if [[ "$ROOT_RESULT" == "Terminal" ]]; then
  hyprctl dispatch exec "kitty"
fi
if [[ "$ROOT_RESULT" == "Launcher" ]]; then
  hyprctl dispatch exec "wofi --show drun"
fi
if [[ "$ROOT_RESULT" == "Workspace Left" ]]; then
  hyprctl dispatch workspace r-1
fi
if [[ "$ROOT_RESULT" == "Workspace Right" ]]; then
  hyprctl dispatch workspace r+1
fi
if [[ "$ROOT_RESULT" == "Kill Active" ]]; then
  hyprctl dispatch killactive
fi
if [[ "$ROOT_RESULT" == "Power" ]]; then
  POWER_RESULT=$(echo -e "Shutdown\nReboot\nReturn to Steam" | wofi --show dmenu --cache-file /dev/null)

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
