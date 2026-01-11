{ ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      display = {
        separator = " 󰑃  ";
      };

      modules = [
        "break"

        {
          type = "os";
          key = " DISTRO";
          keyColor = "yellow";
        }
        {
          type = "kernel";
          key = "│ ├";
          keyColor = "yellow";
        }
        {
          type = "packages";
          key = "│ ├󰏖";
          keyColor = "yellow";
        }
        {
          type = "shell";
          key = "│ └";
          keyColor = "yellow";
        }

        {
          type = "wm";
          key = " DE/WM";
          keyColor = "blue";
        }
        {
          type = "wmtheme";
          key = "│ ├󰉼";
          keyColor = "blue";
        }
        {
          type = "lm";
          key = "│ ├󰍂";
          keyColor = "blue";
        }
        {
          type = "theme";
          key = "│ ├󰉼";
          keyColor = "blue";
        }
        {
          type = "icons";
          key = "│ ├󰀻";
          keyColor = "blue";
        }
        {
          type = "cursor";
          key = "│ ├󰇀";
          keyColor = "blue";
        }
        {
          type = "font";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "command";
          key = "│ └";
          keyColor = "blue";
          text = "( fastfetch -s terminal --pipe -l none; fastfetch -s terminalfont --pipe -l none ) | sed 's/WM //g; s/Theme/-/g' | tr '\\n' ' ' | sed 's/Terminal//g' | sed 's/Font//g' | sed 's/󰑃//g' | cut -c 4- | tr -s ' ' | sed 's/ /, /2'";
        }

        {
          type = "host";
          key = "󰌢 SYSTEM";
          keyColor = "green";
        }
        {
          type = "cpu";
          key = "│ ├";
          keyColor = "green";
        }
        {
          type = "gpu";
          key = "│ ├﬙";
          keyColor = "green";
          format = "{2}";
          detectionMethod = "vulkan";
        }
        {
          type = "display";
          key = "│ ├󰍹";
          keyColor = "green";
          compactType = "original-with-refresh-rate";
        }
        {
          type = "memory";
          key = "│ ├󰾆";
          keyColor = "green";
        }
        {
          type = "display";
          key = "│ └󰍹";
          keyColor = "green";
        }

        {
          type = "sound";
          key = " AUDIO";
          keyColor = "magenta";
          format = "{2}";
        }
        {
          type = "player";
          key = "│ ├󰥠";
          keyColor = "magenta";
        }
        {
          type = "media";
          key = "│ └󰝚";
          keyColor = "magenta";
        }

        {
          type = "custom";
          format = "\u001b[90m  \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m  \u001b[38m  \u001b[39m  \u001b[39m    \u001b[38m  \u001b[37m  \u001b[36m  \u001b[35m  \u001b[34m  \u001b[33m  \u001b[32m  \u001b[31m  \u001b[90m ";
        }

        "break"
      ];
    };

  };
}
