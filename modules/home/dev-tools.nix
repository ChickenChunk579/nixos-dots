# Development tools module
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    starship
    gnumake
    nixfmt
    python3
    git
    clang
    clang-tools
  ];

  programs.neovim.enable = true;
  programs.vscode.enable = true;
}
