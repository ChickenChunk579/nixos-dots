{ config, pkgs, ... }:

let
  installerScript = pkgs.writeShellScript "installer-script" ''
    set -euo pipefail

    clear

    toilet GlacierOS --metal -f bigmono9

    echo "Welcome to the GlacierOS Installer!"

    echo "(1/?) User setup"
    USERNAME=$(gum input --prompt "Username: " --placeholder "your username")
    FULLNAME=$(gum input --prompt "Full name: " --placeholder "Your Full Name")
    PASSWORD=$(gum input --prompt "Password: " --placeholder "your password" --password)
    PASSWORD_CONFIRM=$(gum input --prompt "Confirm password: " --placeholder "your password" --password)
    
    if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
      gum style --foreground 1 "Passwords do not match!"
      exit 1
    fi

    echo "(2/?) Disk"
    DISKS=$(lsblk -dno NAME,TYPE | grep disk | awk '{print $1}')
    DISK=$(echo "$DISKS" | gum choose --header "Select the target disk for installation:")
    echo "Selected disk: /dev/$DISK"

    echo "(3/?) Network"
    NET_TYPE=$(gum choose \
    "Ethernet (DHCP)" \
    "Wi-Fi" \
    "Skip networking")

    case "$NET_TYPE" in
    "Ethernet (DHCP)")
        echo "Configuring Ethernet..."
        nmcli networking on
        nmcli device set eth0 managed yes 2>/dev/null || true
        nmcli device connect eth0 2>/dev/null || true
        gum spin --spinner dot --title "Waiting for network..." -- sleep 3
        ;;

    "Wi-Fi")
        nmcli networking on

        WIFI_DEV=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi"{print $1; exit}')
        if [ -z "$WIFI_DEV" ]; then
        gum style --foreground 1 "No Wi-Fi device found!"
        exit 1
        fi

        echo "Scanning Wi-Fi networks..."
        nmcli device wifi rescan ifname "$WIFI_DEV"
        sleep 2

        WIFI_SSID=$(nmcli -t -f IN-USE,SSID,SECURITY,SIGNAL device wifi list ifname "$WIFI_DEV" \
        | sed '/^:/d' \
        | gum choose --header "Select Wi-Fi network")

        SSID=$(echo "$WIFI_SSID" | cut -d: -f2)
        SEC=$(echo "$WIFI_SSID" | cut -d: -f3)

        if [ "$SEC" != "--" ]; then
        WIFI_PASS=$(gum input --prompt "Wi-Fi password: " --password)
        nmcli device wifi connect "$SSID" password "$WIFI_PASS" ifname "$WIFI_DEV"
        else
        nmcli device wifi connect "$SSID" ifname "$WIFI_DEV"
        fi
        ;;

    "Skip networking")
        echo "Skipping network configuration."
        ;;
    esac

    # Hostname
    HOSTNAME=$(gum input \
    --prompt "Hostname: " \
    --value "$(hostname)")

    echo "(4/?) Timezone"

    # List regions (Africa, America, Europe, etc.)
    REGION=$(ls /etc/zoneinfo \
    | grep -vE '^(posix|right|Etc)$' \
    | gum choose --header "Select your region")

    # List cities for the chosen region
    CITY=$(ls "/etc/zoneinfo/$REGION" \
    | gum choose --header "Select your city")

    TIMEZONE="$REGION/$CITY"

    echo "Selected timezone: $TIMEZONE"

    echo "(5/?) Hardware Detection"
    
    # Detect CPU
    CPU_TYPE=$(grep -o "intel\|amd" /proc/cpuinfo | head -1 || echo "intel")
    echo "Detected CPU: $CPU_TYPE"
    CPU_KERNEL_MOD="kvm-$CPU_TYPE"
    
    # Detect GPU
    GPU_TYPE=""
    if lspci | grep -qi nvidia; then
      GPU_TYPE="nvidia"
    elif lspci | grep -qi amd; then
      GPU_TYPE="amd"
    elif lspci | grep -qi "intel.*graphics"; then
      GPU_TYPE="intel"
    fi
    echo "Detected GPU: ''${GPU_TYPE:-integrated}"

    echo "(6/?) Starting installation"
    echo "(1/3) Partitioning disk"

    TARGET_DISK="/dev/$DISK"

    # Show current disk layout
    echo "Current partitions on $TARGET_DISK:"
    lsblk "$TARGET_DISK"
    echo

    # Preview what will happen (example)
    PARTITION_PLAN="
    $TARGET_DISK will be wiped and repartitioned as:
    - EFI System Partition: 512M
    - Root Partition: remaining space
    "

    echo "$PARTITION_PLAN"

    # Confirm with gum
    if gum confirm "Do you want to proceed with this partitioning?" --default=false; then
    echo "User confirmed. Proceeding with partitioning..."
    
    wipefs -a "$TARGET_DISK"
    parted "$TARGET_DISK" mklabel gpt

    parted -a optimal "$TARGET_DISK" mkpart ESP fat32 1MiB 2049MiB
    parted "$TARGET_DISK" set 1 boot on
    parted -a optimal "$TARGET_DISK" mkpart primary linux-swap 2049MiB 6145MiB
    parted -a optimal "$TARGET_DISK" mkpart primary btrfs 6145MiB 100%

    EFI_PART="''${TARGET_DISK}1"
    SWAP_PART="''${TARGET_DISK}2"
    BTRFS_PART="''${TARGET_DISK}3"

    echo "Formatting EFI as FAT32..."
    mkfs.fat -F32 "$EFI_PART"

    echo "Setting up swap..."
    mkswap "$SWAP_PART"

    echo "Formatting root as Btrfs..."
    mkfs.btrfs -f "$BTRFS_PART"
    
    else
    echo "Partitioning canceled by user. Exiting installer."
    exit 1
    fi

    echo "(2/3) Mounting filesystems"
    mount ''${TARGET_DISK}3 /mnt
    mkdir -p /mnt/boot
    mount ''${TARGET_DISK}1 /mnt/boot
    swapon ''${TARGET_DISK}2

    echo "(3/3) Cloning configuration and generating glacier-config.nix"

    git clone https://github.com/ChickenChunk579/nixos-dots /tmp/glacieros --depth 1 --branch new

    echo "Generating hardware configuration..."
    mkdir -p /mnt/etc/nixos
    nixos-generate-config --root /mnt

    # Extract device UUIDs
    ROOT_UUID=$(grep "device = " /mnt/etc/nixos/hardware-configuration.nix | grep "/" | head -1 | grep -oP '(?<=/dev/disk/by-uuid/)[^"]+' || echo "REPLACE_WITH_UUID")
    BOOT_UUID=$(grep "device = " /mnt/etc/nixos/hardware-configuration.nix | grep "/boot" | grep -oP '(?<=/dev/disk/by-uuid/)[^"]+' || echo "REPLACE_WITH_UUID")
    SWAP_UUID=$(grep "device = " /mnt/etc/nixos/hardware-configuration.nix | tail -1 | grep -oP '(?<=/dev/disk/by-uuid/)[^"]+' || echo "REPLACE_WITH_UUID")

    # Get kernel modules from hardware config
    INIT_MODULES=$(grep -A 1 "boot.initrd.availableKernelModules" /mnt/etc/nixos/hardware-configuration.nix | tail -1 | sed 's/.*\[\(.*\)\].*/\1/')
    KERNEL_MODULES=$(grep -A 1 "boot.kernelModules" /mnt/etc/nixos/hardware-configuration.nix | tail -1 | sed 's/.*\[\(.*\)\].*/\1/')

    # Generate glacier-config.nix
    cat > /tmp/glacieros/glacier-config.nix <<'EOF'
{
  # User Configuration
  username = "$USERNAME";
  fullName = "$FULLNAME";
  timezone = "$TIMEZONE";

  # Security Configuration
  # WARNING: These passwords should NEVER be committed to version control
  password = "$PASSWORD";
  rootPassword = "$PASSWORD";

  # System Configuration
  hostname = "$HOSTNAME";

  # Hardware Configuration
  hardware = {
    cpu = "$CPU_TYPE";
    gpu = "$GPU_TYPE";
    
    # Kernel modules for boot
    kernelModules = [ "$CPU_KERNEL_MOD" ];
    
    # Available kernel modules for initrd
    initrd = {
      availableKernelModules = [ $INIT_MODULES ];
      kernelModules = [ ];
    };
    
    # Extra module packages (usually empty)
    extraModulePackages = [ ];
  };

  # Filesystems Configuration
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/$ROOT_UUID";
      fsType = "btrfs";
    };
    
    "/boot" = {
      device = "/dev/disk/by-uuid/$BOOT_UUID";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  # Swap Configuration
  swapDevices = [
    { device = "/dev/disk/by-uuid/$SWAP_UUID"; }
  ];

  # Platform Configuration
  hostPlatform = "x86_64-linux";

  # System Version
  stateVersion = "25.11";
}
EOF

    echo "Installing system..."
    nixos-install --root /mnt --flake /tmp/glacieros#alpha --no-root-passwd

    echo "Configuring root password..."
    nixos-enter --root /mnt -- bash -c "echo 'root:$PASSWORD' | chpasswd"

    echo "Installation complete!"
    gum style --foreground 2 "GlacierOS has been successfully installed!"
    gum style "Reboot your system to complete the installation."
  '';
in
{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.networkmanager.enable = true;

  networking.hostName = "nixos-installer";
  time.timeZone = "UTC";

  users.users.root = {
    initialHashedPassword = "";
  };

  environment.systemPackages = [
    pkgs.fastfetch
    pkgs.toilet
    pkgs.gum
    pkgs.fzf
    pkgs.git
  ];

  ### Add script to global bashrc ###
  environment.interactiveShellInit = ''
    if [ -z "''${INSTALLER_RAN:-}" ]; then
      export INSTALLER_RAN=1
      sudo ${installerScript}
    fi
  '';

  services.openssh.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
in
{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.networkmanager.enable = true;

  networking.hostName = "nixos-installer";
  time.timeZone = "UTC";

  users.users.root = {
    initialHashedPassword = "";
  };

  environment.systemPackages = [
    pkgs.fastfetch
    pkgs.toilet
    pkgs.gum
    pkgs.fzf
    pkgs.git
  ];

  ### Add script to global bashrc ###
  environment.interactiveShellInit = ''
    if [ -z "''${INSTALLER_RAN:-}" ]; then
      export INSTALLER_RAN=1
      sudo ${installerScript}
    fi
  '';

  services.openssh.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
