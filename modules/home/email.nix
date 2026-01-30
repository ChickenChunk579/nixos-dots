{ pkgs, lib, glacier, ... }:

let
  inherit (lib) mkIf;
  emailClient = glacier.programs.emailClient;
in
{
  config = lib.mkMerge [
    # Thunderbird email client
    (mkIf (emailClient == "thunderbird") {
      home.packages = with pkgs; [
        thunderbird
      ];
    })

    # No email client
    (mkIf (emailClient == "none") {
      # Empty config, no email client installed
    })

    # Assertions
    {
      assertions = [
        {
          assertion = (emailClient == "thunderbird" || emailClient == "none");
          message = "programs.emailClient must be one of: thunderbird, none";
        }
      ];
    }
  ];
}
