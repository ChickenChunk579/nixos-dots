SYSTEM = $(shell cat system.txt)


test:
	nix build .#nixosConfigurations.$(SYSTEM).config.system.build.toplevel --no-link

switch:
	sudo nixos-rebuild switch --flake .#$(SYSTEM)

.PHONY: test switch