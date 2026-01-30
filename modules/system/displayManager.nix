{ config, lib, pkgs, glacier, ... }:

let
  inherit (lib) mkIf mkDefault mkMerge;
  displayManager = glacier.displayManager.name;
  
  # Custom Hyprland session
  custom-hyprland-session =
    pkgs.runCommand "custom-hyprland-session"
      {
        passthru.providedSessions = [ "hyprland-custom" ];
      }
      ''
        mkdir -p $out/share/wayland-sessions
        cat <<EOF > $out/share/wayland-sessions/hyprland-custom.desktop
        [Desktop Entry]
        Name=Hyprland (Custom)
        Comment=Launch Hyprland properly
        Exec=${pkgs.hyprland}/bin/Hyprland
        Type=Application
        EOF
      '';
in
{
  config = mkMerge [
    {
      services.displayManager.sessionPackages = [ custom-hyprland-session ];
    }

    # LY Display Manager
    (mkIf (displayManager == "ly") {
      services.displayManager.ly.enable = true;
    })

    # SDDM Display Manager
    (mkIf (displayManager == "sddm") {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = mkDefault glacier.displayManager.sddm.wayland;
        settings.General.DisplayServer = mkIf glacier.displayManager.sddm.wayland "wayland";
      };
    })

    # LightDM Display Manager
    (mkIf (displayManager == "lightdm") {
      services.xserver.enable = true;
      services.xserver.displayManager.lightdm = {
        enable = true;
        greeters.slick.enable = mkDefault (glacier.displayManager.lightdm.greeter == "slick");
        greeters.gtk.enable = mkDefault (glacier.displayManager.lightdm.greeter == "gtk");
      };
    })

    # GDM Display Manager
    (mkIf (displayManager == "gdm") {
      services.displayManager.gdm = {
        enable = true;
        wayland = mkDefault glacier.displayManager.gdm.wayland;
      };
    })

    # Ensure only one display manager is enabled
    {
      assertions = [
        {
          assertion =
            (displayManager == "ly"
              || displayManager == "sddm"
              || displayManager == "lightdm"
              || displayManager == "gdm");
          message = "displayManager.name must be one of: ly, sddm, lightdm, gdm";
        }
      ];
    }
  ];
}
