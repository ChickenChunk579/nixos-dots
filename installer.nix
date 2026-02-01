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

    [ "$CHOICE" = "Recovery Shell" ] && exit 0

    # ===== 1. User Setup =====
    section "1/12 - User Setup"
    USERNAME=$(gum input --prompt "Username: ")
    FULLNAME=$(gum input --prompt "Full name: ")
    PASSWORD=$(gum input --prompt "Password: " --password)
    PASSWORD_CONFIRM=$(gum input --prompt "Confirm password: " --password)

    [ "$PASSWORD" != "$PASSWORD_CONFIRM" ] && gum style --foreground 1 "Passwords do not match!" && exit 1

    # ===== 2. Disk Selection =====
    section "2/12 - Disk Selection"
    DISK=$(lsblk -dno NAME,TYPE | awk '$2=="disk"{print $1}' | gum choose)
    TARGET_DISK="/dev/$DISK"

    # ===== 3. Network Setup =====
    section "3/12 - Network Setup"
    NET_TYPE=$(gum choose "Ethernet (DHCP)" "Wi-Fi" "Skip")

    if [ "$NET_TYPE" != "Skip" ]; then
      nmcli networking on
    fi

    # ===== 4. Hostname =====
    section "4/12 - Hostname"
    HOSTNAME=$(gum input --prompt "Hostname: " --value "$(hostname)")

    # ===== 5. Timezone =====
    section "5/12 - Timezone"
    REGION=$(ls /etc/zoneinfo | grep -vE '^(posix|right|Etc)$' | gum choose)
    CITY=$(ls "/etc/zoneinfo/$REGION" | gum choose)
    TIMEZONE="$REGION/$CITY"

    # ===== 6. Hardware Detection =====
    section "6/12 - Hardware Detection"
    CPU_TYPE=$(grep -o "intel\|amd" /proc/cpuinfo | head -1 || echo "intel")
    CPU_KERNEL_MOD="kvm-$CPU_TYPE"

    GPU_TYPE="integrated"
    lspci | grep -qi nvidia && GPU_TYPE="nvidia"
    lspci | grep -qi amd && GPU_TYPE="amd"
    lspci | grep -qi "intel.*graphics" && GPU_TYPE="intel"

    # ===== 7. Desktop & UI Selection =====
    section "7/12 - Desktop & UI"

    WINDOW_MANAGER=$(gum choose \
      gnome \
      plasma \
      cosmic \
      hyprland \
      mangowc)

    EMAIL_CLIENT=$(gum choose thunderbird none)

    DISPLAY_MANAGER=$(gum choose \
      sddm \
      gdm \
      lightdm)

    # ===== 8. Module Selection =====
    section "8/12 - Optional Modules"

    SELECTED_MODULES=$(gum choose --no-limit \
      virtualization \
      networking \
      gaming \
      podman \
      flatpak \
      fonts \
      devTools \
      media \
      audio \
      productivity \
      gaming_home \
      utilities \
      gtkTheme \
      cad)

    enable_module() {
      echo "$SELECTED_MODULES" | grep -qw "$1" && echo "true" || echo "false"
    }

    # ===== 9. Partition Disk =====
    section "9/12 - Partitioning Disk"
    gum confirm "Wipe and partition $TARGET_DISK?" || exit 1

    wipefs -a "$TARGET_DISK"
    parted "$TARGET_DISK" mklabel gpt
    parted -a optimal "$TARGET_DISK" mkpart ESP fat32 1MiB 2049MiB
    parted "$TARGET_DISK" set 1 boot on
    parted -a optimal "$TARGET_DISK" mkpart primary linux-swap 2049MiB 6145MiB
    parted -a optimal "$TARGET_DISK" mkpart primary btrfs 6145MiB 100%

    EFI_PART="''${TARGET_DISK}1"
    SWAP_PART="''${TARGET_DISK}2"
    ROOT_PART="''${TARGET_DISK}3"

    mkfs.fat -F32 "$EFI_PART"
    mkswap "$SWAP_PART"
    mkfs.btrfs -f "$ROOT_PART"

    mount "$ROOT_PART" /mnt
    mkdir -p /mnt/boot
    mount "$EFI_PART" /mnt/boot
    swapon "$SWAP_PART"

    # ===== 10. Config Generation =====
    section "10/12 - Generating Config"

    git clone https://github.com/ChickenChunk579/nixos-dots /mnt/glacieros --depth 1 --branch new
    nixos-generate-config --root /mnt

    BOOT_UUID=$(blkid -s UUID -o value "$EFI_PART")
    ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")
    SWAP_UUID=$(blkid -s UUID -o value "$SWAP_PART")

    cat > /mnt/glacier-config.nix <<EOF
    {
      username = "$USERNAME";
      fullName = "$FULLNAME";
      hostname = "$HOSTNAME";
      timezone = "$TIMEZONE";

      programs = {
        windowManager = "$WINDOW_MANAGER";
        emailClient = "$EMAIL_CLIENT";
        browser = "firefox";
      };

      displayManager = {
        name = "$DISPLAY_MANAGER";
      };

      hardware = {
        cpu = "$CPU_TYPE";
        gpu = "$GPU_TYPE";
        kernelModules = ["$CPU_KERNEL_MOD"];
      };

      fileSystems = {
        "/" = { device = "/dev/disk/by-uuid/$ROOT_UUID"; fsType = "btrfs"; };
        "/boot" = { device = "/dev/disk/by-uuid/$BOOT_UUID"; fsType = "vfat"; };
      };

      swapDevices = [{ device = "/dev/disk/by-uuid/$SWAP_UUID"; }];

      modules = {
        virtualization = $(enable_module virtualization);
        networking = $(enable_module networking);
        gaming = $(enable_module gaming);
        podman = $(enable_module podman);
        flatpak = $(enable_module flatpak);
        fonts = $(enable_module fonts);

        devTools = $(enable_module devTools);
        media = $(enable_module media);
        audio = $(enable_module audio);
        productivity = $(enable_module productivity);
        gaming_home = $(enable_module gaming_home);
        utilities = $(enable_module utilities);
        gtkTheme = $(enable_module gtkTheme);
        cad = $(enable_module cad);
      };

      hostPlatform = "x86_64-linux";
      stateVersion = "25.11";
    }
    EOF

    # ===== 11. Install =====
    section "11/12 - Installing"
    nixos-install --impure --root /mnt --flake /mnt/glacieros#glacier --no-root-passwd

    nixos-enter --root /mnt -- bash -c "
    echo 'root:$PASSWORD' | chpasswd
    echo '$USERNAME:$PASSWORD' | chpasswd
    "

    # ===== 12. Finish =====
    section "12/12 - Done"
    gum choose Reboot Shutdown Shell | grep -q Reboot && reboot || shutdown now
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
    pkgs.nix-output-monitor
  ];

  environment.interactiveShellInit = ''
    if [ -z "''${INSTALLER_RAN:-}" ]; then
      export INSTALLER_RAN=1
      sudo ${installerScript}
    fi
  '';

  boot.initrd.availableKernelModules = [
    "xhci_pci" # USB 3.0
    "usb_storage" # Standard USB sticks
    "uas" # USB Attached SCSI (faster modern drives)
    "sd_mod" # SCSI disk support (USB drives often appear as /dev/sdX)
    "nvme" # If booting from internal NVMe during install
    "ahci" # Standard SATA controllers
  ];

  services.openssh.enable = false;
  networking.firewall.enable = false;

  image.fileName = "glacier-x86_64-linux.iso";

  system.stateVersion = "25.11";
}
