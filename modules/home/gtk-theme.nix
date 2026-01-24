# GTK theme and icons
{ pkgs, ... }:
{
  gtk.enable = true;
  gtk.iconTheme.package = pkgs.zafiro-icons;
  gtk.iconTheme.name = "Zafiro-icons-Dark";
}
