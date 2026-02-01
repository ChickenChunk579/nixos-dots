{
  pkgs,
  lib,
  mango,
  ...
}:

let
  glacier = import /glacier-config.nix;
in

{
  _module.args = { inherit glacier; };
  imports = [
    ./wofi.nix
    ./quickshell/main.nix
    ./hyprshade/main.nix
    ./hypridle.nix
    ./nixwal.nix
    ./fastfetch.nix
    ./matugen.nix
    ./scripts.nix
    ./gtk-theme.nix
    ./email.nix
    mango.hmModules.mango
  ]
  # Optional home-manager modules
  ++ (lib.optionals glacier.modules.audio [ ./audio.nix ])
  ++ (lib.optionals glacier.modules.devTools [ ./dev-tools.nix ])
  ++ (lib.optionals glacier.modules.media [ ./media.nix ])
  ++ (lib.optionals glacier.modules.productivity [ ./productivity.nix ])
  ++ (lib.optionals glacier.modules.cad [ ./cad.nix ])
  ++ (lib.optionals glacier.modules.gaming_home [ ./gaming.nix ])
  ++ (lib.optionals glacier.modules.utilities [ ./utilities.nix ])
  ++ (lib.optionals (glacier.programs.windowManager == "mangowc") [ ./mangowc/main.nix ])
  ++ (lib.optionals (glacier.programs.windowManager == "hyprland") [ ./hyprland/main.nix ])
  ++ (lib.optionals (glacier.programs.browser == "firefox") [ ./firefox.nix ])
  ++ (lib.optionals (glacier.programs.browser == "chromium") [ ./chromium.nix ]);

  home = {
    # Base packages (always installed)
    packages = with pkgs; [
      # Base Hyprland dependencies
      swww              # Wallpaper manager
      hyprlock          # Screen locker
      hypridle          # Idle management
      matugen           # Color scheme generator
      
      # Base applications
      kitty             # Terminal
      
      # Color management
      pywal
      
      # Basic utilities
      git
      github-cli

      starship
      gnumake
      wget
      kdePackages.qt6ct
      localsend
    ];
    
    username = glacier.username;
    homeDirectory = "/home/${glacier.username}";
    stateVersion = glacier.stateVersion;

    sessionVariables = {
      EDITOR = "nano";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };
  };

  home.file.".bashrc".text = ''
    eval -- "$(/etc/profiles/per-user/${glacier.username}/bin/starship init bash --print-full-init)"
  '';

  home.file.".steam/steam/.cef-enable-remote-debugging".text = "1";

  home.sessionPath = [ "~/.local/bin" ];

  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = 0.8;
      blur = true;
      confirm_os_window_close = 0;
    };
    extraConfig = ''
      include ~/.config/kitty/matugen.conf
    '';
  };

  systemd.user.services.restart-seatd = {
    Unit = {
      Description = "Restart seatd after logout";
      After = ["graphical-session.target"];
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart seatd";
    };
  };
}
