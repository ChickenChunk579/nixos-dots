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
          ({ lib, pkgs, ... }: {
            imports = [
              (
                # Put the most recent revision here:
                let
                  revision = "bb53a85db9210204a98f771f10f1f5b4e06ccb2d";
                in
                builtins.fetchTarball {
                  url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/${revision}.tar.gz";
                  # Update the hash as needed:
                  sha256 = "sha256:0ybg3bcyspayj9l8003iyqj5mphmivw8q6s5d1n2r6mdr99il5za";
                }
                + "/modules"
              )
            ];

            jovian.steam.enable = true;
            jovian.steam.autoStart = true;
            jovian.steam.user = "rhys";
            jovian.decky-loader.enable = true;
            jovian.steam.desktopSession = "hyprland-custom";
            services.displayManager.sddm.enable = lib.mkForce false;
          })
          home-manager.nixosModules.home-manager
          hyprland.nixosModules.default
        ];
      };
    };
}
