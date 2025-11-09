HOSTNAME:=$(shell hostnamectl hostname)

.PHONY: all nixos home-manager

home-manager-nh:
	nh home switch . -c ${USER} --impure

update:
	nix flake update

all: nixos home-manager

nixos:
	sudo nixos-rebuild switch --flake .#${HOSTNAME}

home-manager:
	home-manager switch --flake .#${USER} -b backup

bootstrap-home-manager:
	nix run --extra-experimental-features "nix-command flakes" home-manager -- switch --extra-experimental-features "nix-command flakes" --flake .#${USER} -b backup
