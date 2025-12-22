.PHONY: update-flake update-dots update

SYSTEM := $(shell cat system.txt)

update-dots:
	cp dotfiles/.bashrc ~/.bashrc
	rsync -av dotfiles/* ~/.config

update-flake:
	sudo nixos-rebuild switch --flake .#${SYSTEM}

update: update-flake update-dots
