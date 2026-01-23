{ config, pkgs, ... }:

{
  ### Basic bootable system ###
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # change if needed

  networking.hostName = "nixos-installer";
  time.timeZone = "UTC";

  ### No login required ###
  services.getty.autologinUser = "root";

  users.users.root = {
    initialHashedPassword = "";
  };

  ### Define the startup script in Nix ###
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "installer-script" ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "Installer script running..."
      echo "Hello from NixOS installer!"

      # example actions
      lsblk
      sleep 2

      echo "Done."
      # poweroff   # uncomment if you want auto-shutdown
    '')
  ];

  ### Run the script automatically at boot ###
  systemd.services.installer-script = {
    description = "Run installer script at boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c installer-script";
      StandardOutput = "tty";
      StandardError = "tty";
      TTYPath = "/dev/tty1";
      RemainAfterExit = true;
    };
  };

  ### Minimal defaults ###
  services.openssh.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "25.11"; # change to match your base
}
