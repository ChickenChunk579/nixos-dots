test:
	nix build .#nixosConfigurations.alpha.config.system.build.toplevel --no-link

switch:
	sudo nixos-rebuild switch --flake .#alpha-deck

.PHONY: test switch