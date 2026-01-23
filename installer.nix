{ config, pkgs, ... }:

let
  installerScript = pkgs.writeShellScript "installer-script" ''
    set -euo pipefail

    clear

    toilet GlacierOS --metal -f bigmono9

    echo "Welcome to the GlacierOS Installer!"

    echo "(1/?) User setup"
    gum input --prompt "Username: " --placeholder "your username" > /tmp/installer-username
    gum input --prompt "Full name: " --placeholder "Your Full Name" > /tmp/installer-fullname
    gum input --prompt "Password: " --placeholder "your password" --password > /tmp/installer-password
    gum input --prompt "Confirm password: " --placeholder "your password" --password > /tmp/installer-password

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

    echo "$HOSTNAME" > /tmp/installer-hostname

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

    # Persist for installer use
    echo "$TIMEZONE" > /tmp/installer-timezone

    echo "(5/?) Starting installation"
    echo "(1/?) Partitioning disk"

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

    echo "(2/?) Mounting filesystems"
    mount ''${TARGET_DISK}3 /mnt
    mkdir -p /mnt/boot
    mount ''${TARGET_DISK}1 /mnt/boot
    swapon ''${TARGET_DISK}2

    echo "(3/?) Cloning configuration"

    git clone https://github.com/ChickenChunk579/nixos-dots /tmp/glacieros --depth 1 --branch new

    echo "(4/?) Generating configuration"
    mkdir -p /mnt/etc/nixos
    nixos-generate-config --root /mnt
    rm /tmp/glacieros/systems/alpha.nix
    cp /mnt/etc/nixos/hardware-configuration.nix /tmp/glacieros/systems/alpha.nix

    echo "(5/?) Installing system"

    nixos-install --root /mnt --flake /tmp/glacieros#alpha --no-root-passwd

    echo "(6/?) Post-install configuration"
    ROOT_PASS=$(< /tmp/installer-password)

    nixos-enter --root /mnt -- bash -c "echo 'root:$ROOT_PASS' | chpasswd"


    echo "Done."
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
