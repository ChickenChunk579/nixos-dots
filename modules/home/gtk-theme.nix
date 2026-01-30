# GTK theme and icons
{ pkgs, ... }:
{
  gtk.enable = true;
  gtk.iconTheme.package = pkgs.zafiro-icons;
  gtk.iconTheme.name = "Zafiro-icons-Dark";
  gtk.cursorTheme = {
    package = pkgs.oreo-cursors-plus;
    name = "oreo_black_cursors";
  };
}
