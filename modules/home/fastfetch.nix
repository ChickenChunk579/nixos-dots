{ ... }:
{
  home.file.".config/fastfetch/glacier.txt".text = ''
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⣠⢤⣄⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣟⠷⡏⡀⣿⡿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⡆⠀⣴⡟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⡟⡆⠀⠀⠀⠀⠀⣴⢤⣀⡇⠀⢻⣀⡶⢦⠀⠀⠀⠀⠀⡴⢦⠀⠀⠀⠀
⠀⣴⠟⠻⡇⣷⡀⠀⡏⢻⠀⠙⢦⡉⠻⡄⠞⣁⡴⠏⠀⣠⣦⠀⠀⣇⢸⣦⠶⣦⠀
⠀⢙⣷⢯⡄⠉⠻⢦⣧⢸⡆⠀⠀⠈⡏⠀⢾⠃⠀⠀⠀⡇⢸⣀⠶⠻⠈⠀⢴⣞⣀
⠈⢯⠵⠚⠛⠳⣤⣀⠙⠈⢷⣄⠀⣀⡇⠀⢸⣄⠀⢀⣠⠗⠘⠁⣀⡴⠚⠛⠲⠼⠟
⠀⠀⠀⠀⠀⡟⣉⣼⠶⢦⣀⠈⠛⠁⠀⠀⠀⠈⠛⠉⢀⣷⣦⣌⡙⠳⢦⡄⠀⠀⠀
⠀⠀⠀⠀⠀⠉⠁⠀⠀⠀⠙⣷⠀⠀⠀⠀⠀⠀⠀⢺⠋⠁⠀⠀⠉⠙⠛⠀⠀⠀⠀
⠀⠀⠀⠀⣾⠓⠶⢤⣀⣀⡴⠟⠀⠀⠀⠀⠀⠀⠀⠺⣆⡀⢀⣠⡴⢶⠀⠀⠀⠀⠀
⢀⣀⡀⠀⠀⢉⣳⠶⠌⠁⣀⣴⢶⣄⡀⠀⢀⣠⡷⣄⡀⠙⠫⣵⣖⠉⠀⠀⣠⣤⠀
⠙⢧⣭⡽⠒⠋⢁⣠⡆⢹⠉⠀⠀⠈⡏⠉⣿⠁⠀⠈⢹⡕⣤⡀⠉⠳⢖⣋⡽⠟⠁
⠀⡞⠉⢀⡄⣶⠋⠡⣇⣸⠀⠀⣀⡴⡃⠀⡛⢦⣀⠀⠈⣇⢸⠙⠲⣤⠈⠉⠳⣦⠀
⠀⠉⠉⠉⣇⣿⠀⠀⠈⠁⠀⣿⣁⡴⡟⠀⣿⢦⣌⣳⠀⠹⠾⠃⠀⢸⣈⣷⠶⠟⠀
⠀⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀⠈⠁⢀⡇⠀⣿⡀⠈⠉⠀⠀⠀⠀⠀⠈⠙⠋⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡤⢚⡅⠀⣭⡛⢦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠿⠉⣧⢀⣾⠉⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  '';

  programs.fastfetch = {
    enable = true;
    settings = {
      display = {
        separator = " 󰑃  ";
      };

      logo = {
        type = "file";
        source = "/home/rhys/.config/fastfetch/glacier.txt";
      };

      modules = [
        "break"

        {
          type = "os";
          key = " DISTRO";
          keyColor = "yellow";
          format = "Glacier OS 25.11 x86_64";
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
        "break"
      ];
    };

  };
}
