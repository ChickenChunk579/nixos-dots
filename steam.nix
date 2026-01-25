{ lib, pkgs, glacier, ... }: {
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
  jovian.steam.desktopSession =
    lib.mkIf (glacier.programs.windowManager == "hyprland") "hyprland-custom"
    // lib.mkIf (glacier.programs.windowManager == "mangowc") "mango";
  services.displayManager.sddm.enable = lib.mkForce false;
  
  # Override isDeck to true for deck configurations
  # This should merge with the existing extraSpecialArgs from configuration.nix
  home-manager.extraSpecialArgs.isDeck = lib.mkForce true;
}