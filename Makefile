SYSTEM = $(shell cat system.txt)

test:
	nix build .#nixosConfigurations.$(SYSTEM).config.system.build.toplevel --no-link

switch:
	sudo nixos-rebuild switch --flake .#$(SYSTEM) --show-trace
	pkill elephant 2>/dev/null || true
	elephant >/dev/null 2>&1 & disown

installer:
	nix build .#nixosConfigurations.installer.config.system.build.isoImage

test-installer:
	qemu-system-x86_64 \
		-m 8G \
		-cdrom ./result/iso/nixos-minimal-25.11.20260107.d351d06-x86_64-linux.iso \
		-bios ../OVMFbin/OVMF_CODE-pure-efi.fd \
		-drive file=disk.qcow2,format=qcow2 \
		-netdev user,id=net0,hostfwd=tcp::2222-:22 \
		-device e1000,netdev=net0 \
		-device virtio-vga \
		-enable-kvm \
		-cpu host

test-installed:
	qemu-system-x86_64 \
		-m 8G \
		-bios ../OVMFbin/OVMF_CODE-pure-efi.fd \
		-drive file=disk.qcow2,format=qcow2 \
		-netdev user,id=net0,hostfwd=tcp::2222-:22 \
		-device e1000,netdev=net0 \
		-device virtio-gpu-pci \
		-enable-kvm \
		-cpu host


.PHONY: test switch installer test-installer test-installed 