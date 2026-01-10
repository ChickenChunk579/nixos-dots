{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";

    hyprland.url = "github:hyprwm/Hyprland";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      hyprland,
      home-manager,
      elephant,
      walker,
      jovian,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.alpha = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit hyprland walker;
        };

        modules = [
          ./configuration.nix
          ./systems/alpha.nix
          home-manager.nixosModules.home-manager
          hyprland.nixosModules.default
        ];
      };

      # New system for the Deck using Jovian / Steam Deck UI.
      nixosConfigurations.alpha-deck = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit hyprland walker jovian;
        };

        modules = [
          ./configuration.nix
          ./systems/alpha.nix
          ./steam.nix
          home-manager.nixosModules.home-manager
          hyprland.nixosModules.default
        ];
      };



      nixosConfigurations.beta = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit hyprland walker;
        };

        modules = [
          ./configuration.nix
          ./systems/beta.nix
          home-manager.nixosModules.home-manager
          hyprland.nixosModules.default
        ];
      };

      # New system for the Deck using Jovian / Steam Deck UI.
      nixosConfigurations.beta-deck = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit hyprland walker jovian;
        };

        modules = [
          ./configuration.nix
          ./systems/beta.nix
          ./steam.nix
          {
            jovian.devices.steamdeck.enable = true;
          }
          home-manager.nixosModules.home-manager
          hyprland.nixosModules.default
        ];
      };
    };
}
