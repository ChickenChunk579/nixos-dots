#!/usr/bin/env bash
# generate-glacier-config.sh - Generate or update glacier-config.nix for an existing system

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "''${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== GlacierOS Configuration Generator ===${NC}"
echo ""

# Check if running as root for hardware detection
if [ "$EUID" -ne 0 ]; then
   echo -e "${YELLOW}Warning: Not running as root. Hardware detection may be incomplete.${NC}"
fi

# Existing values detection
if [ -f "$SCRIPT_DIR/glacier-config.nix" ]; then
    echo -e "${GREEN}Found existing glacier-config.nix${NC}"
    echo ""
fi

# Get current values from system if possible
CURRENT_HOSTNAME=$(hostname)
CURRENT_TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "Europe/London")

# User Configuration
echo -e "${BLUE}User Configuration${NC}"
read -p "Username (current: ${USER}): " USERNAME
USERNAME=${USERNAME:-$USER}

read -p "Full name: " FULLNAME

read -p "Timezone (current: $CURRENT_TIMEZONE): " TIMEZONE
TIMEZONE=${TIMEZONE:-$CURRENT_TIMEZONE}

read -p "Hostname (current: $CURRENT_HOSTNAME): " HOSTNAME
HOSTNAME=${HOSTNAME:-$CURRENT_HOSTNAME}

# Hardware Detection
echo ""
echo -e "${BLUE}Hardware Detection${NC}"

# Detect CPU
CPU_TYPE="intel"
if grep -q "AuthenticAMD" /proc/cpuinfo 2>/dev/null; then
    CPU_TYPE="amd"
fi
echo -e "Detected CPU type: ${GREEN}$CPU_TYPE${NC}"

# Detect GPU
GPU_TYPE=""
if lspci 2>/dev/null | grep -qi nvidia; then
    GPU_TYPE="nvidia"
elif lspci 2>/dev/null | grep -qi "amd.*graphics"; then
    GPU_TYPE="amd"
elif lspci 2>/dev/null | grep -qi "intel.*graphics"; then
    GPU_TYPE="intel"
fi
echo -e "Detected GPU: ${GREEN}${GPU_TYPE:-integrated}${NC}"

# Filesystem Configuration
echo ""
echo -e "${BLUE}Filesystem Configuration${NC}"
echo "Detecting filesystems..."

# Function to safely extract UUID from blkid output
get_fs_uuid() {
    local target=$1
    blkid -s UUID -o value "$target" 2>/dev/null || echo "REPLACE_WITH_UUID"
}

# Detect filesystems
ROOT_DEV=$(findmnt -n -o SOURCE / 2>/dev/null || echo "/dev/")
BOOT_DEV=$(findmnt -n -o SOURCE /boot 2>/dev/null || echo "/dev/")
SWAP_DEV=""

if [ "$EUID" -eq 0 ]; then
    ROOT_UUID=$(get_fs_uuid "$ROOT_DEV")
    BOOT_UUID=$(get_fs_uuid "$BOOT_DEV")
    # Try to find swap device
    for swap_dev in $(swapon --show=DEVNAME --noheadings); do
        SWAP_DEV="$swap_dev"
        break
    done
    if [ -n "$SWAP_DEV" ]; then
        SWAP_UUID=$(get_fs_uuid "$SWAP_DEV")
    else
        SWAP_UUID="REPLACE_WITH_UUID"
    fi
else
    ROOT_UUID="REPLACE_WITH_UUID"
    BOOT_UUID="REPLACE_WITH_UUID"
    SWAP_UUID="REPLACE_WITH_UUID"
    echo -e "${YELLOW}Run with sudo for automatic UUID detection${NC}"
fi

echo "Root filesystem UUID: $ROOT_UUID"
echo "Boot filesystem UUID: $BOOT_UUID"
echo "Swap device UUID: $SWAP_UUID"

# Get kernel modules from nixos
echo ""
echo -e "${BLUE}Detecting kernel modules...${NC}"

INIT_MODULES="xhci_pci ahci usbhid usb_storage sd_mod"
KERNEL_MOD="kvm-$CPU_TYPE"

# Try to read from current system config
if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    INIT_MODULES=$(grep -A 1 "boot.initrd.availableKernelModules" /etc/nixos/hardware-configuration.nix 2>/dev/null | tail -1 | sed 's/.*\[\(.*\)\].*/\1/' || echo "xhci_pci ahci usbhid usb_storage sd_mod")
fi

echo "Kernel modules: $KERNEL_MOD"
echo "Initrd modules: $INIT_MODULES"

# Generate glacier-config.nix
OUTPUT_FILE="$SCRIPT_DIR/glacier-config.nix"

cat > "$OUTPUT_FILE" <<EOF
{
  # User Configuration
  username = "$USERNAME";
  fullName = "$FULLNAME";
  timezone = "$TIMEZONE";

  # Security Configuration
  # WARNING: These passwords should NEVER be committed to version control
  password = ""; # Set via 'passwd' after installation
  rootPassword = ""; # Set via 'sudo passwd' after installation

  # System Configuration
  hostname = "$HOSTNAME";

  # Hardware Configuration
  hardware = {
    cpu = "$CPU_TYPE";
    gpu = "$GPU_TYPE";
    
    # Kernel modules for boot
    kernelModules = [ "$KERNEL_MOD" ];
    
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

echo ""
echo -e "${GREEN}✓ Configuration generated successfully!${NC}"
echo ""
echo -e "${BLUE}File saved to:${NC} $OUTPUT_FILE"
echo ""
echo -e "${YELLOW}Important:${NC} Review the generated file and update any REPLACE_WITH_UUID placeholders if needed."
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review $OUTPUT_FILE"
echo "2. Run 'make switch' to apply the configuration"
echo "3. Use 'passwd' to set your user password"
echo "4. Use 'sudo passwd' to set root password"
