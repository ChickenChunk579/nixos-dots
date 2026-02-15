# Development tools module
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gnumake
    nixfmt
    python3
    git
    clang
    clang-tools
    rustc
    cargo
  ];

  programs.neovim.enable = true;
  programs.vscode.enable = true;
}
