SYSTEM = glacier

test:
	nix build .#nixosConfigurations.$(SYSTEM).config.system.build.toplevel --no-link

switch:
	sudo nixos-rebuild switch --flake .#$(SYSTEM) --show-trace
	pkill elephant 2>/dev/null || true
	elephant >/dev/null 2>&1 & disown

.PHONY: test switch
