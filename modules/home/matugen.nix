{ pkgs, ... }:
{
  home.packages = with pkgs; [
    matugen
  ];

  home.file.".config/matugen/config.toml".text = ''
    [templates.quickshell]
    input_path = '~/.config/matugen/templates/quickshell.json'
    output_path = '~/.cache/wal/colors.json
  '';

  home.file.".config/matugen/templates/quickshell.json".text = ''
    {
        "wallpaper": "{{image}}",

        "special": {
            "background": "{{colors.on_surface}}",
            "lighterBackground": "{{colors.on_surface_variant}}",
            "foreground": "{{colors.primary}}",
        },
        "colors": {
            "color0": "#1a1e21",
            "color1": "#5B8678",
            "color2": "#36758D",
            "color3": "#50718A",
            "color4": "#6A778F",
            "color5": "#5291AB",
            "color6": "#53B0CC",
            "color7": "#9edae2",
            "color8": "#6e989e",
            "color9": "#5B8678",
            "color10": "#36758D",
            "color11": "#50718A",
            "color12": "#6A778F",
            "color13": "#5291AB",
            "color14": "#53B0CC",
            "color15": "#9edae2"
        }
    }
  '';
}