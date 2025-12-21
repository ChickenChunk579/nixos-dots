{
  description = "My Home Manager Configuration.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland"; # IMPORTANT
    };
  };

  outputs =
    { nixpkgs, home-manager , ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.steamdeck-oled = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hw-configs/steamdeck-oled.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rhys = import ./home.nix;
          }
          {
            jovian.steam.enable = true;
            jovian.steam.autoStart = true;
            jovian.steam.desktopSession = "hyprland";
            jovian.steam.user = "rhys";

            jovian.devices.steamdeck.enable = true;
          }
        ];
      };
      nixosConfigurations.xc895 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hw-configs/xc895.nix
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rhys = import ./home.nix;
          }
          {
            services.displayManager.ly.enable = true;
          }
        ];
      };

      nixosConfigurations.xc895-deck = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hw-configs/xc895.nix
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rhys = import ./home.nix;
          }
          {
            jovian.steam.enable = true;
            jovian.steam.autoStart = true;
            jovian.steam.desktopSession = "hyprland";
            jovian.steam.user = "rhys";

            environment.systemPackages = with pkgs; [
              gamescope
              gamescope-session
            ];
          }
        ];
      };
    };
}
