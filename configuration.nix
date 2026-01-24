{
  config,
  lib,
  pkgs,
  nixos-grub-themes,
  mango,
  ...
}:

let
  glacier = import /glacier-config.nix;
  
  # This defines the custom entry with the required metadata
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
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.theme = nixos-grub-themes.packages.${pkgs.system}.nixos;
  boot.loader.grub.extraEntries = ''
    menuentry "macOS (OpenCore)" {
      insmod part_gpt
      insmod fat
      search --no-floppy --set=root --file /EFI/OC/OpenCore.efi
      chainloader /EFI/OC/OpenCore.efi
    }
  '';
  boot = {
    initrd.availableKernelModules = glacier.hardware.initrd.availableKernelModules;
    initrd.kernelModules = glacier.hardware.initrd.kernelModules;
    kernelModules = glacier.hardware.kernelModules;
    extraModulePackages = glacier.hardware.extraModulePackages;

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

  # Filesystem configuration from glacier-config.nix
  fileSystems = glacier.fileSystems;
  swapDevices = glacier.swapDevices;

  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];
  networking.hostName = glacier.hostname;

  time.timeZone = glacier.timezone;

  users.groups.plugdev = { };

  users.users."${glacier.username}" = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "plugdev"
      "networkmanager"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
    ];
    extraSpecialArgs = {
      isDeck = false;
      inherit mango;
    };
    users."${glacier.username}" = import ./modules/home/home.nix;
  };

  environment.systemPackages = with pkgs; [
    nano
    cage
    swayosd
  ];
  
  # Import optional system modules
  imports = lib.optionals glacier.modules.virtualization [ ./modules/system/virtualization.nix ]
    ++ lib.optionals glacier.modules.networking [ ./modules/system/networking.nix ]
    ++ lib.optionals glacier.modules.gaming [ ./modules/system/gaming.nix ]
    ++ lib.optionals glacier.modules.podman [ ./modules/system/podman.nix ]
    ++ lib.optionals glacier.modules.flatpak [ ./modules/system/flatpak.nix ];
  
  virtualisation.libvirtd.enable = lib.mkDefault false;
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

  programs.nix-ld.enable = true;

  system.stateVersion = glacier.stateVersion;

  nix.settings.extra-experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = glacier.hostPlatform;

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;

  services.blueman.enable = true;

  programs.hyprland.enable =
    lib.mkIf (glacier.programs.windowManager == "hyprland") true;

  programs.mango.enable =
    lib.mkIf (glacier.programs.windowManager == "mangowc") true;


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

  services.flatpak.enable = lib.mkDefault false;

  programs.steam.enable = lib.mkDefault false;
  programs.steam.extest.enable = lib.mkDefault false;

  virtualisation.podman = {
    enable = lib.mkDefault false;
    dockerCompat = lib.mkDefault false;
  };


  hardware.enableRedistributableFirmware = true;
}
