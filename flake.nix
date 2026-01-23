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

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixos-grub-themes.url = "github:jeslie0/nixos-grub-themes";
  };

  outputs = {
    self,
    nixpkgs,
    hyprland,
    home-manager,
    elephant,
    walker,
    jovian,
    spicetify-nix,
    nixos-grub-themes
  }:
  let
    system = "x86_64-linux";
    glacier = import ./glacier-config.nix;
    
    # Common modules for all systems
    commonModules = [
      ./configuration.nix
      home-manager.nixosModules.home-manager
      hyprland.nixosModules.default
    ];
    
    # Special args passed to all modules
    commonSpecialArgs = {
      inherit hyprland walker nixos-grub-themes;
    };
    
    # Deck-specific modules
    deckModules = commonModules ++ [
      ./steam.nix
      {
        jovian.devices.steamdeck.enable = true;
      }
    ];
    
    deckSpecialArgs = commonSpecialArgs // {
      inherit jovian;
    };
  in
  {
    nixosConfigurations = {
      glacier = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs;
        modules = commonModules;
      };

      glacier-deck = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = deckSpecialArgs;
        modules = deckModules;
      };

      installer = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs;
        modules = [
          ./installer.nix
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          home-manager.nixosModules.home-manager
          hyprland.nixosModules.default
        ];
      };
    };
  };
}
