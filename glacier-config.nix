{
  # User Configuration
  username = "rhys";
  fullName = "Rhys Tumelty";
  timezone = "Europe/London";

  # System Configuration
  hostname = "glacier";

  # Hardware Configuration
  hardware = {
    # Kernel modules for boot
    kernelModules = [ "kvm-intel" ]; # kvm-intel for Intel, kvm-amd for AMD
    
    # Available kernel modules for initrd
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    };
    
    # Extra module packages (usually empty)
    extraModulePackages = [ ];
  };

  # Filesystems Configuration
  fileSystems."/" =
  { device = "/dev/disk/by-uuid/d4b95a0d-8321-4e15-be98-3e19ddfd1842";
      fsType = "btrfs";
  };
  
  fileSystems."/boot" =
  { device = "/dev/disk/by-uuid/F0AC-959E";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
  };
  
  swapDevices =
  [ { device = "/dev/disk/by-uuid/742b9f25-caa2-4efd-af21-80db4f0b56d3"; }
  ];

  # Platform Configuration
  hostPlatform = "x86_64-linux";

  # System Version
  stateVersion = "25.11";

  # System Modules - enable/disable optional features
  # Base modules (always enabled): quickshell, hyprland, walker, firefox, kitty
  modules = {
    # System-level modules
    virtualization = true;    # QEMU, virt-manager, distrobox
    networking = true;        # VPN, networking tools
    gaming = false;             # Steam
    podman = false;            # Container runtime
    flatpak = false;           # Flatpak runtime

    # Home-manager modules
    devTools = true;          # Development tools (neovim, vscode, etc)
    media = false;             # Media tools (GIMP, OBS, mpv, etc)
    audio = false;             # Audio tools (Spicetify, etc)
    productivity = false;      # Productivity apps (Obsidian, etc)
    gaming_home = true;       # Gaming apps (Godot, osu!, etc)
    utilities = true;         # Utilities (syncthing, etc)
  };
}
