{ pkgs, glacier, ... }:

let
  isGnome = glacier.programs.windowManager == "gnome";

  wallpaperCommand =
    if isGnome then
      "gsettings"
    else
      "swww";

  wallpaperArguments =
    if isGnome then
      [
        "set"
        "org.gnome.desktop.background"
        "picture-uri"
      ]
    else
      [
        "img"
        "--transition-type"
        "center"
      ];
in
{
  home.packages = with pkgs; [
    matugen
  ];

  home.file.".config/matugen/config.toml".text = ''
    [config]
    version_check = false

    [config.wallpaper]
    command = "${wallpaperCommand}"
    arguments = ${builtins.toJSON wallpaperArguments}
    set = true

    [templates.gtk3]
    input_path = '~/.config/matugen/templates/gtk.css'
    output_path = '~/.themes/Matugen/gtk-3.0/gtk.css'
    
    [templates.gtk4]
    input_path = '~/.config/matugen/templates/gtk.css'
    output_path = '~/.config/gtk-4.0/gtk.css'

    [templates.quickshell]
    input_path = '~/.config/matugen/templates/quickshell.json'
    output_path = '~/.config/quickshell/colors.json'

    [templates.hypr]
    input_path = '~/.config/matugen/templates/hypr.conf'
    output_path = '~/.config/hypr/matugen.conf'
    post_hook = 'hyprctl reload'

    [templates.kitty]
    input_path = '~/.config/matugen/templates/kitty.conf'
    output_path = '~/.config/kitty/matugen.conf'
    post_hook = 'pkill -USR1 -f kitty'

    [templates.pywalfox]
    input_path = '~/.config/matugen/templates/pywalfox.json'
    output_path = '~/.cache/wal/colors.json'
    post_hook = 'pywalfox update'

    [templates.vscode]
    input_path = '~/.config/matugen/templates/vscode.json'
    output_path = '~/.config/Code/User/settings.json'

    [templates.mango]
    input_path = '~/.config/matugen/templates/mango.conf'
    output_path = '~/.config/mango/matugen.conf'
    post_hook = 'mmsg -d reload_config'

  '';

  home.file.".config/matugen/templates/quickshell.json".text = ''
    {
        "wallpaper": "{{image}}",

        "special": {
            "background": "{{colors.surface_container_low.dark.hex}}",
            "lighterBackground": "{{colors.surface_container.dark.hex}}",
            "foreground": "{{colors.primary.dark.hex}}"
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

  home.file.".config/matugen/templates/hypr.conf".text = ''
    $image = {{image}}

    <* for name, value in colors *>
    ''${{name}} = rgba({{value.default.hex_stripped}}ff)
    <* endfor *>
  '';

  home.file.".config/matugen/templates/kitty.conf".text = ''
    cursor {{colors.on_surface.default.hex}}
    cursor_text_color {{colors.on_surface_variant.default.hex}}

    foreground            {{colors.on_surface.default.hex}}
    background            {{colors.surface.default.hex}}
    selection_foreground  {{colors.on_secondary.default.hex}}
    selection_background  {{colors.secondary_fixed_dim.default.hex}}
    url_color             {{colors.primary.default.hex}}

    # black
    color8   #262626
    color0   #4c4c4c

    # red
    color1   #ac8a8c
    color9   #c49ea0

    # green
    color2   #8aac8b
    color10  #9ec49f

    # yellow
    color3   #aca98a
    color11  #c4c19e

    # blue
    /* color4  #8f8aac */
    color4  {{colors.primary.default.hex}}
    color12 #a39ec4

    # magenta
    color5   #ac8aac
    color13  #c49ec4

    # cyan
    color6   #8aacab
    color14  #9ec3c4

    # white
    color15   #e7e7e7
    color7  #f0f0f0
  '';

  home.file.".config/matugen/templates/pywalfox.json".text = ''
    {
      "wallpaper": "{{image}}",
      "alpha": "100",
      "colors": {
        "color0": "{{colors.background.default.hex}}",
        "color1": "",
        "color2": "",
        "color3": "",
        "color4": "",
        "color5": "",
        "color6": "",
        "color7": "",
        "color8": "",
        "color9": "",
        "color10": "{{colors.primary.default.hex}}",
        "color11": "",
        "color12": "",
        "color13": "{{colors.surface_bright.default.hex}}",
        "color14": "",
        "color15": "{{colors.on_surface.default.hex}}"
      }
    }
  '';

  home.file.".config/matugen/templates/vscode.json".text = ''
    {
      "material-code.colors": {
        // All fields are optional. Unset colors are derived from primary
        "primary": "{{colors.primary.default.hex}}",

        "foreground": "{{colors.on_surface.default.hex}}",
        "mutedForeground": "{{colors.on_surface_variant.default.hex}}",
        "background": "{{colors.surface.default.hex}}",
        // Elevated panel
        "card": "{{colors.surface_container.default.hex}}",
        // Dialog, dropdown
        "popover": "{{colors.surface_container_high.default.hex}}",
        // Hover, selected
        "hover": "{{colors.surface_container_highest.default.hex}}",
        // Input border, divider
        "border": "{{colors.outline_variant.default.hex}}",
        "primaryForeground": "{{colors.on_primary.default.hex}}",
        // Tonal button, tooltip
        "secondary": "{{colors.secondary_container.default.hex}}",
        "secondaryForeground": "{{colors.on_secondary_container.default.hex}}",
        "error": "",
        "errorForeground": "",
        // Success indicators, green terminal colors
        "success": "",
        // Warning indicators, yellow terminal colors
        "warning": "",
        "syntax.comment": "",
        "syntax.string": "",
        // Keywords, operators, control flow
        "syntax.keyword": "",
        // Variables, tags, HTML elements
        "syntax.variable": "",
        // HTML attributes, CSS selectors
        "syntax.attribute": "",
        // Object properties, CSS properties
        "syntax.property": "",
        // Functions, methods, CSS values
        "syntax.function": "",
        // Numbers, constants, types
        "syntax.constant": "",
        // Bracket pair colors
        "syntax.bracket1": "",
        "syntax.bracket2": "",
        "syntax.bracket3": "",
        "syntax.bracket4": ""
      },
      "workbench.colorTheme": "Material Code"
    }
  '';

  home.file.".config/matugen/templates/gtk.css".text = ''
    /*
    * GTK Colors
    * Generated with Matugen
    */

    * {
      font-weight: 500;
      font-family: "Roboto", sans-serif;
    }

    @define-color accent_color {{colors.primary_fixed_dim.default.hex}};
    @define-color accent_fg_color {{colors.on_primary_fixed.default.hex}};
    @define-color accent_bg_color {{colors.primary_fixed_dim.default.hex}};
    @define-color window_bg_color {{colors.surface_dim.default.hex}};
    @define-color window_fg_color {{colors.on_surface.default.hex}};
    @define-color headerbar_bg_color {{colors.surface_dim.default.hex}};
    @define-color headerbar_fg_color {{colors.on_surface.default.hex}};
    @define-color popover_bg_color {{colors.surface_dim.default.hex}};
    @define-color popover_fg_color {{colors.on_surface.default.hex}};
    @define-color view_bg_color {{colors.surface.default.hex}};
    @define-color view_fg_color {{colors.on_surface.default.hex}};
    @define-color card_bg_color {{colors.surface.default.hex}};
    @define-color card_fg_color {{colors.on_surface.default.hex}};
    @define-color sidebar_bg_color @window_bg_color;
    @define-color sidebar_fg_color @window_fg_color;
    @define-color sidebar_border_color @window_bg_color;
    @define-color sidebar_backdrop_color @window_bg_color;
  '';

  home.file.".config/matugen/templates/mango.conf".text = ''
    # Cor do fundo do ecrã
    rootcolor={{colors.background.dark.hex_stripped}}ff

    # Cor da borda para janelas inativas
    bordercolor={{colors.outline_variant.dark.hex_stripped}}ff

    # Cor da borda para a janela em foco
    focuscolor={{colors.primary_container.dark.hex_stripped}}ff

    # Cor para janelas maximizadas
    maxmizescreencolor={{colors.secondary.dark.hex_stripped}}ff

    # Cor para janelas urgentes
    urgentcolor={{colors.error.dark.hex_stripped}}ff

    # Cor para o scratchpad
    scratchpadcolor={{colors.tertiary.dark.hex_stripped}}ff

    # Cor para janelas globais
    globalcolor={{colors.secondary_container.dark.hex_stripped}}ff

    # Cor para janelas em modo overlay
    overlaycolor={{colors.tertiary_container.dark.hex_stripped}}ff
  '';
}