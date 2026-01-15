{
  config,
  lib,
  pkgs,
  hyprland,
  walker,
  ...
}:

let
  # This defines the custom entry with the required metadata
  custom-hyprland-session = pkgs.runCommand "custom-hyprland-session" 
    {
      passthru.providedSessions = [ "hyprland-custom" ];
    }
    ''
      mkdir -p $out/share/wayland-sessions
      cat <<EOF > $out/share/wayland-sessions/hyprland-custom.desktop
      [Desktop Entry]
      Name=Hyprland (Custom)
      Comment=Launch Hyprland properly
      Exec=${hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland}/bin/Hyprland
      Type=Application
      EOF
    '';
in
{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot = {

    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = with pkgs; [
        # By default we would install all themes
        nixos-bgrt-plymouth
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

  };
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];

  time.timeZone = "Europe/London";

  users.groups.plugdev = { };

  users.users.rhys = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "plugdev"
      "networkmanager"
      "libvirtd"
    ];
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [

    ];
    extraSpecialArgs = {
      inherit walker hyprland;
      isDeck = false;
    };
    users.rhys = import ./modules/home/home.nix;
  };

  environment.systemPackages = with pkgs; [
    nano
    cage
    swayosd
    wireguard-tools
    protonvpn-gui
    qemu
    qemu_kvm
  ];
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  services.udev.packages = [ pkgs.swayosd ];

  systemd.services.swayosd-libinput-backend = {
    description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc.";
    documentation = [ "https://github.com/ErikReider/SwayOSD" ];
    wantedBy = [ "graphical.target" ];
    partOf = [ "graphical.target" ];
    after = [ "graphical.target" ];

    serviceConfig = {
      Type = "dbus";
      BusName = "org.erikreider.swayosd";
      ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
      Restart = "on-failure";
    };
  };

  services.dbus.enable = true;
  #services.dbus.socketActivated = true;


  networking.firewall.enable = false;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  system.stateVersion = "25.11";

  nix.settings.extra-experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;

  services.blueman.enable = true;

  programs.hyprland = {
    enable = true;    

    # set the flake package
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  services.displayManager.sessionPackages = [ custom-hyprland-session ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
    material-design-icons
    roboto
  ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.flatpak.enable = true;

  programs.steam.enable = true;
  programs.steam.extest.enable = true;
}
