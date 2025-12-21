.PHONY: update-flake update-dots update

update-dots:
	cp dotfiles/.bashrc ~/.bashrc
	rsync -av dotfiles/* ~/.config

update-flake:
	sudo nixos-rebuild switch --flake .#nixos

update: update-flake update-dots
