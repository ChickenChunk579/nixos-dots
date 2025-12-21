# NixOS Dots
My personal NixOS dotfiles using Flakes and Home Manager.

# Installation
1. Partition and format disks
2. Mount all mountpoints relative to /mnt
3. Clone this repository to /etc/nixos
3. Run `sudo nixos-generate-config --show-hardware-config --root /mnt` and copy the content into `hardware-config.nix`
4. Run `sudo nixos-install --flake /mnt/etc/nixos#nixos` to install the system
5. Reboot into the Installation
6. Switch to tty2 and log in as root
7. Set a password for your user and `su` into it.
8. Copy content of /etc/nixos into ~/nix
9. Run `chown {your user name} ~/nix`
10. In ~/nix, run `make update`
