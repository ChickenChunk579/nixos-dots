{ config, lib, pkgs, glacier, ... }:

let
  virt = glacier.modules.virtualization or false;
in
lib.mkIf virt {
  virtualisation = {
    libvirtd.enable = true;

    podman.enable =
      glacier.modules.podman or false;
  };

  boot.kernelModules = glacier.boot.kernelModules or [ ];
  boot.kernelParams  = glacier.boot.kernelParams  or [ ];

  programs.virt-manager.enable = true;

  hardware.opengl.enable = true;

  users.groups.libvirtd.members = [ glacier.username ];
}
