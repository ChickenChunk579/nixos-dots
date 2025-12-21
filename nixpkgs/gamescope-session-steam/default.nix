# /etc/nixos/nixpkgs/gamescope-session-steam/default.nix
{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, stdenv ? pkgs.stdenv, fetchgit ? pkgs.fetchgit, ... }:

stdenv.mkDerivation rec {
  pname = "gamescope-session-steam";
  version = "0.1.0";

  src = fetchgit {
    url = "https://github.com/ChimeraOS/gamescope-session-steam";
    rev = "1a3fdb7fa15a4bba7204bef69702b7a10a297828";
    sha256 = "sha256-jlrqb4GReTETCke5klrkRFIafKy/k/icNi7CmgziuLk=";
  };

  # ChimeraOS scripts often need specific paths adjusted for NixOS
  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/
  '';

  meta = with lib; {
    description = "Gamescope session scripts for Steam";
    license = licenses.mit; # Verify license from source
  };
}

