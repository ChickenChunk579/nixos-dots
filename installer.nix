{ config, pkgs, ... }:

let
  installerScript = pkgs.writeShellScript "installer-script" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # ===== ANSI Helpers =====
    ESC="\033"
    RESET="''${ESC}[0m"
    BOLD="''${ESC}[1m"
    DIM="''${ESC}[2m"

    RED="''${ESC}[31m"
    GREEN="''${ESC}[32m"
    YELLOW="''${ESC}[33m"
    BLUE="''${ESC}[34m"
    MAGENTA="''${ESC}[35m"
    CYAN="''${ESC}[36m"
    GRAY="''${ESC}[90m"

    hr() {
      printf "''${GRAY}%*s''${RESET}\n" "$(tput cols)" "" | tr ' ' '─'
    }

    section() {
      clear
      hr
      printf "''${BOLD}''${CYAN}  %s''${RESET}\n" "$1"
      hr
      echo
    }

    typewriter() {
      while IFS= read -r -n1 c; do
        printf "%s" "$c"
        sleep 0.005
      done
      echo
    }

    # ===== Intro =====
    clear
    toilet GlacierOS --metal -f bigmono9

    echo
    gum style \
      --border rounded \
      --border-foreground cyan \
      --padding "1 4" \
      --align center \
      "Welcome to the GlacierOS Installer"

    CHOICE=$(gum choose \
      --header "Select an option:" \
      "Install" \
      "Recovery Shell")

    case "$CHOICE" in
      "Install")
        gum style --foreground 2 "Continuing installation..."
        ;;
      "Recovery Shell")
        gum style --foreground 3 "Dropping to recovery shell..."
        exit 0
        ;;
    esac

    # ===== 1. User Setup =====
    section "1/10 - User Setup"
    USERNAME=$(gum input --prompt "Username: " --placeholder "your username")
    FULLNAME=$(gum input --prompt "Full name: " --placeholder "Your Full Name")
    PASSWORD=$(gum input --prompt "Password: " --placeholder "your password" --password)
    PASSWORD_CONFIRM=$(gum input --prompt "Confirm password: " --placeholder "your password" --password)
    
    if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
      gum style --foreground 1 "Passwords do not match!"
      exit 1
    fi

    # ===== 2. Disk Selection =====
    section "2/10 - Disk Selection"
    DISKS=$(lsblk -dno NAME,TYPE | grep disk | awk '{print $1}')
    DISK=$(echo "$DISKS" | gum choose --header "Select the target disk for installation:")
    gum style --foreground 2 "Selected disk: /dev/$DISK"

    # ===== 3. Network Setup =====
    section "3/10 - Network Setup"
    NET_TYPE=$(gum choose \
      "Ethernet (DHCP)" \
      "Wi-Fi" \
      "Skip networking")

    case "$NET_TYPE" in
      "Ethernet (DHCP)")
        gum style --foreground 2 "Configuring Ethernet..."
        nmcli networking on
        nmcli device set eth0 managed yes 2>/dev/null || true
        nmcli device connect eth0 2>/dev/null || true
        gum spin --spinner "pulse" --title "Waiting for network..." -- sleep 3
        ;;
      "Wi-Fi")
        nmcli networking on
        WIFI_DEV=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi"{print $1; exit}')
        if [ -z "$WIFI_DEV" ]; then
          gum style --foreground 1 "No Wi-Fi device found!"
          exit 1
        fi
        gum style --foreground 2 "Scanning Wi-Fi networks..."
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
        gum style --foreground 3 "Skipping network configuration."
        ;;
    esac

    # ===== 4. Hostname =====
    section "4/10 - Hostname"
    HOSTNAME=$(gum input --prompt "Hostname: " --value "$(hostname)")

    # ===== 5. Timezone =====
    section "5/10 - Timezone"
    REGION=$(ls /etc/zoneinfo | grep -vE '^(posix|right|Etc)$' | gum choose --header "Select your region")
    CITY=$(ls "/etc/zoneinfo/$REGION" | gum choose --header "Select your city")
    TIMEZONE="$REGION/$CITY"
    gum style --foreground 2 "Selected timezone: $TIMEZONE"

    # ===== 6. Hardware Detection =====
    section "6/10 - Hardware Detection"
    CPU_TYPE=$(grep -o "intel\|amd" /proc/cpuinfo | head -1 || echo "intel")
    CPU_KERNEL_MOD="kvm-$CPU_TYPE"
    GPU_TYPE=""
    if lspci | grep -qi nvidia; then GPU_TYPE="nvidia"; 
    elif lspci | grep -qi amd; then GPU_TYPE="amd";
    elif lspci | grep -qi "intel.*graphics"; then GPU_TYPE="intel"; fi
    gum style --foreground 2 "Detected CPU: $CPU_TYPE"
    gum style --foreground 2 "Detected GPU: ''${GPU_TYPE:-integrated}"

    # ===== 7. Partitioning Disk =====
    section "7/10 - Partitioning Disk"
    TARGET_DISK="/dev/$DISK"
    gum style --foreground 2 "Current partitions on $TARGET_DISK:"
    lsblk "$TARGET_DISK"
    echo
    PARTITION_PLAN="
    $TARGET_DISK will be wiped and repartitioned as:
    - EFI System Partition: 512M
    - Swap Partition: 4G
    - Root Partition: remaining space
    "
    gum style --foreground 3 "$PARTITION_PLAN"
    if ! gum confirm "Proceed with this partitioning?" --default=false; then
      gum style --foreground 1 "Partitioning canceled. Exiting."
      exit 1
    fi

    gum spin --spinner "pulse" --title "Wiping and partitioning disk..." -- bash -c "
      wipefs -a '$TARGET_DISK'
      parted '$TARGET_DISK' mklabel gpt
      parted -a optimal '$TARGET_DISK' mkpart ESP fat32 1MiB 2049MiB
      parted '$TARGET_DISK' set 1 boot on
      parted -a optimal '$TARGET_DISK' mkpart primary linux-swap 2049MiB 6145MiB
      parted -a optimal '$TARGET_DISK' mkpart primary btrfs 6145MiB 100%
    "

    EFI_PART="''${TARGET_DISK}1"
    SWAP_PART="''${TARGET_DISK}2"
    BTRFS_PART="''${TARGET_DISK}3"

    gum spin --spinner "pulse" --title "Formatting partitions..." -- bash -c "
      mkfs.fat -F32 '$EFI_PART'
      mkswap '$SWAP_PART'
      mkfs.btrfs -f '$BTRFS_PART'
    "

    # ===== 8. Mount Filesystems =====
    section "8/10 - Mounting Filesystems"
    mount "$BTRFS_PART" /mnt
    mkdir -p /mnt/boot
    mount "$EFI_PART" /mnt/boot
    swapon "$SWAP_PART"

    # ===== 9. Clone Config & Generate glacier-config.nix =====
    section "9/10 - Config Setup"
    git clone https://github.com/ChickenChunk579/nixos-dots /mnt/glacieros --depth 1 --branch new
    mkdir -p /mnt/etc/nixos
    nixos-generate-config --root /mnt

    BOOT_UUID=$(blkid -s UUID -o value "$EFI_PART")
    ROOT_UUID=$(blkid -s UUID -o value "$BTRFS_PART")
    SWAP_UUID=$(blkid -s UUID -o value "$SWAP_PART")

    INIT_MODULES=$(sed -n 's/.*boot.initrd.availableKernelModules = \[\(.*\)\];/\1/p' /mnt/etc/nixos/hardware-configuration.nix)

    cat > /mnt/glacier-config.nix <<EOF
{
  username = "$USERNAME";
  fullName = "$FULLNAME";
  timezone = "$TIMEZONE";

  password = "";
  rootPassword = "";

  hostname = "$HOSTNAME";

  hardware = {
    cpu = "$CPU_TYPE";
    gpu = "$GPU_TYPE";
    kernelModules = ["$CPU_KERNEL_MOD"];
    initrd = {
      availableKernelModules = [$INIT_MODULES];
      kernelModules = [];
    };
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = { device = "/dev/disk/by-uuid/$ROOT_UUID"; fsType = "btrfs"; };
    "/boot" = { device = "/dev/disk/by-uuid/$BOOT_UUID"; fsType = "vfat"; options = ["fmask=0022" "dmask=0022"]; };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/$SWAP_UUID"; }];

  hostPlatform = "x86_64-linux";
  stateVersion = "25.11";

  modules = {
    virtualization = false;
    networking = false;
    gaming = false;
    podman = false;
    flatpak = false;
    fonts = false;

    devTools = false;
    media = false;
    audio = false;
    productivity = false;
    gaming_home = false;
    utilities = false;
    gtkTheme = false;
  };
}
EOF

    # ===== 10. Install System =====
    section "10/10 - Installing System"
    nixos-install --impure --root /mnt --flake /mnt/glacieros#glacier --no-root-passwd

    gum spin --spinner "pulse" --title "Configuring passwords..." -- bash -c "
      nixos-enter --root /mnt -- bash -c \"echo 'root:$PASSWORD' | chpasswd\"
      nixos-enter --root /mnt -- bash -c \"echo '$USERNAME:$PASSWORD' | chpasswd\"
    "

    gum style --foreground 2 "GlacierOS has been successfully installed!"

    CHOICE=$(gum choose "Shutdown" "Reboot" "Shell")
    case "$CHOICE" in
      "Shutdown") shutdown now ;;
      "Reboot") reboot ;;
      "Shell") exit 0 ;;
    esac

  '';
in
{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.networkmanager.enable = true;
  networking.hostName = "nixos-installer";
  time.timeZone = "UTC";

  users.users.root = { initialHashedPassword = ""; };

  environment.systemPackages = [
    pkgs.fastfetch
    pkgs.toilet
    pkgs.gum
    pkgs.fzf
    pkgs.git
    pkgs.nix-output-monitor
  ];

  environment.interactiveShellInit = ''
    if [ -z "''${INSTALLER_RAN:-}" ]; then
      export INSTALLER_RAN=1
      sudo ${installerScript}
    fi
  '';


  boot.initrd.availableKernelModules = [ 
    "xhci_pci"     # USB 3.0
    "usb_storage"  # Standard USB sticks
    "uas"          # USB Attached SCSI (faster modern drives)
    "sd_mod"       # SCSI disk support (USB drives often appear as /dev/sdX)
    "nvme"         # If booting from internal NVMe during install
    "ahci"         # Standard SATA controllers
  ];

  
  services.openssh.enable = false;
  networking.firewall.enable = false;

  image.fileName = "glacier-x86_64-linux.iso";

  system.stateVersion = "25.11";
}
