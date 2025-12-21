{ config, lib, pkgs, ... }:

{
  imports = [
    (
      # Put the most recent revision here:
      let revision = "bb53a85db9210204a98f771f10f1f5b4e06ccb2d"; in
      builtins.fetchTarball {
        url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/${revision}.tar.gz";
        # Update the hash as needed:
        sha256 = "sha256:0ybg3bcyspayj9l8003iyqj5mphmivw8q6s5d1n2r6mdr99il5za";
      } + "/modules"
    )
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
    gamescope
    gamescope-session
    mesa
  ];

  #services.displayManager.ly.enable = true;
  programs.hyprland.enable = true;
  programs.steam.enable = true;

  networking.firewall.enable = false;
  
  system.stateVersion = "25.11";

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ];

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  hardware.opengl.enable = true;
  
  jovian.steam.enable = true;

  jovian.steam.autoStart = true;

  jovian.steam.desktopSession = "hyprland";

  jovian.steam.user = "rhys";

  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };
}

