{ pkgs, lib, ... }:

let
  pywal-spicetify =
    pkgs.callPackage ./pkgs/pywal-spicetify.nix {};

  marketplace = pkgs.fetchzip {
    url = "https://github.com/spicetify/marketplace/releases/download/v1.0.8/marketplace.zip";
    sha256 = "sha256-JDitawSDegAOA8eGDW5U/1aBLOfErCn6lg2SxEO4i18="; 
  };

  spicetifyThemes = pkgs.fetchgit {
    url = "https://github.com/spicetify/spicetify-themes.git";
    rev = "HEAD"; # or pick a commit hash for reproducibility
    sha256 = "sha256-7KSB8sFXnEC6XUhmtmP5khgTNlbm7uCR9fj1KyCX4Ko="; # replace with real hash
  };
in
{
  home.packages = with pkgs; [
    spicetify-cli
    pywal-spicetify
  ];

  home.file.".config/spicetify/config-xpui.ini".text = ''
    [Preprocesses]
    expose_apis        = 1
    disable_sentry     = 1
    disable_ui_logging = 1
    remove_rtl_rule    = 1

    [AdditionalOptions]
    extensions            = 
    custom_apps           = 
    sidebar_config        = 0
    home_config           = 1
    experimental_features = 1

    [Patch]

    [Setting]
    spotify_path           = $HOME/.local/share/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/
    prefs_path             = /home/rhys/.var/app/com.spotify.Client/config/spotify/prefs
    current_theme          = Dribbblish
    color_scheme           = pywal
    inject_theme_js        = 1
    inject_css             = 1
    replace_colors         = 1
    overwrite_assets       = 0
    spotify_launch_flags   = 
    check_spicetify_update = 1
    always_enable_devtools = 0

    ; DO NOT CHANGE!
    [Backup]
    version = 1.2.74.477.g3be53afe
    with    = 2.42.1
  '';

  # Symlink the extracted marketplace zip into the correct folder
  home.file.".config/spicetify/CustomApps/marketplace".source = marketplace;
  home.activation.copySpicetifyThemes = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Only copy if the folder doesn't exist
    if [ ! -d "$HOME/.config/spicetify/Themes" ]; then
      cp -r "${spicetifyThemes}" "$HOME/.config/spicetify/Themes"
      chown -R $USER "$HOME/.config/spicetify/Themes"
      chmod -R u+rw ~/.config/spicetify/Themes
      echo "Copied ${spicetifyThemes} to $HOME/.config/spicetify/Themes"
    else
      echo "Themes folder already exists, skipping copy"
    fi
  '';

  home.activation.linkXresources = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Remove any existing ~/.Xresources
    rm -f "$HOME/.Xresources"

    # Create a symlink to the pywal-generated file
    if [ -f "$HOME/.cache/wal/colors.Xresources" ]; then
      ln -s "$HOME/.cache/wal/colors.Xresources" "$HOME/.Xresources"
      echo "Linked ~/.Xresources -> ~/.cache/wal/colors.Xresources"
    else
      echo "Warning: ~/.cache/wal/colors.Xresources does not exist yet"
    fi
  '';

}
