{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.rhys = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };
  
  environment.systemPackages = with pkgs; [
    neovim
    wget
    home-manager
    git
    gnumake
    hello
    rose-pine-cursor
    lm_sensors
  ];

  services.displayManager.ly.enable = true;
  programs.hyprland.enable = true;

  networking.firewall.enable = false;
  
  system.stateVersion = "25.11";

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ];

}

