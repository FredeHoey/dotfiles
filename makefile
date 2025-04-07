HOSTNAME:=$(shell cat /etc/hostname)

.PHONY: all nixos home-manager

all: nixos home-manager

nixos:
	sudo nixos-rebuild switch --flake .#${HOSTNAME}

home-manager:
	nix run home-manager -- switch --flake .#${USER}

bootstrap-home-manager:
	nix run --extra-experimental-features "nix-command flakes" home-manager -- switch --extra-experimental-features "nix-command flakes" --flake .#${USER}
