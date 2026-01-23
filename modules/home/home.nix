{
  pkgs,
  walker,
  hyprland,
  lib,
  ...
}:

let
  glacier = import ../../glacier-config.nix;
in

{
  imports = [
    # Base modules (always enabled)
    walker.homeManagerModules.default
    ./hyprland/main.nix
    ./walker.nix
    ./quickshell/main.nix
    ./hyprshade/main.nix
    ./hypridle.nix
    ./nixwal.nix
    ./fastfetch.nix
    ./matugen.nix
  ]
  # Optional home-manager modules
  ++ (lib.optionals glacier.modules.audio [ ./audio.nix ])
  ++ (lib.optionals glacier.modules.devTools [ ./dev-tools.nix ])
  ++ (lib.optionals glacier.modules.media [ ./media.nix ])
  ++ (lib.optionals glacier.modules.productivity [ ./productivity.nix ])
  ++ (lib.optionals glacier.modules.gaming_home [ ./gaming.nix ])
  ++ (lib.optionals glacier.modules.utilities [ ./utilities.nix ]);

  home = {
    # Base packages (always installed)
    packages = with pkgs; [
      # Base Hyprland dependencies
      swww              # Wallpaper manager
      hyprpaper         # Alternative wallpaper
      hyprlock          # Screen locker
      hypridle          # Idle management
      matugen           # Color scheme generator
      material-cursors
      zafiro-icons
      
      # Base applications
      kitty             # Terminal
      firefox           # Browser
      
      # Color management
      pywal
      
      # Basic utilities
      git
      material-design-icons
      roboto
    ];
    
    username = glacier.username;
    homeDirectory = "/home/${glacier.username}";
    stateVersion = glacier.stateVersion;

    sessionVariables = {
      EDITOR = "nano";
      NIXOS_OZONE_WL = "1";
    };
  };

  gtk.enable = true;
  gtk.iconTheme.package = pkgs.zafiro-icons;
  gtk.iconTheme.name = "Zafiro-icons-Dark";

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
  
  programs.firefox.enable = true;

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
