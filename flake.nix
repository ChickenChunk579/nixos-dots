{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixos-grub-themes.url = "github:jeslie0/nixos-grub-themes";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    jovian,
    mango,
    spicetify-nix,
    nixos-grub-themes,
  }:
  let
    system = "x86_64-linux";
    glacier = import /glacier-config.nix;
    
    # Common modules for all systems
    commonModules = [
      ./configuration.nix
      {
        boot.kernelPackages = if glacier.gvtg-kernel 
          then nixpkgs.legacyPackages.${system}.linuxPackages_5_15 
          else nixpkgs.legacyPackages.${system}.linuxPackages_latest;
        
        systemd.services.gvtg-mdev = if glacier.gvtg-kernel then {
          description = "Create Intel GVT-g mdev on boot";
          after = [ "multi-user.target" ]; # run after most devices are ready
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = ''
              /bin/sh -c 'echo "32d895d8-0507-11f1-8fbd-838c700f95fc" | tee /sys/bus/pci/devices/0000:00:02.0/mdev_supported_types/i915-GVTg_V5_4/create'
            '';
            RemainAfterExit = true;
          };
        } else {};

        virtualisation.kvmgt.enable = true;
      }
      home-manager.nixosModules.home-manager
      mango.nixosModules.mango
    ];
    
    # Special args passed to all modules
    commonSpecialArgs = {
      inherit nixos-grub-themes mango glacier;
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
      glacier-regular = nixpkgs.lib.nixosSystem {
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
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
