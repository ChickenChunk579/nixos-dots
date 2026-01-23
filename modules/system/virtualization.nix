{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    qemu
    virt-manager
    distrobox
  ];
  
  virtualisation.libvirtd.enable = true;
}
