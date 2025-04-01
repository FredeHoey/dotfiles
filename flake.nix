{
  description = "Bun dotfiles nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixgl";
    stylix.url = "github:danth/stylix";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      base = [ ./common/base.nix ];
      createSystem = (system-file:
        let name = nixpkgs.lib.strings.removeSuffix ".nix" system-file;
        in {
          inherit name;
          value = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = base ++ [ (./systems + "/${system-file}") ];
          };
        });
    in {
      nixosConfigurations = builtins.listToAttrs
        (map createSystem (builtins.attrNames (builtins.readDir ./systems)));

      homeConfigurations =
        let pkgs = import nixpkgs { system = "x86_64-linux"; };
        in {
          bun = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit (inputs) nixvim stylix; };
            modules = [ ./users/bun.nix ];
          };
        };

      formatter."x86_64-linux" =
        nixpkgs.legacyPackages."x86_64-linux".nixfmt-classic;
    };
}
