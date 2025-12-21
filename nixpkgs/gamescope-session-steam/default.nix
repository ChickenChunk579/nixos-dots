{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4fe8d07066f6ea82cda2b0c9ae7aee59b2d241b3.tar.gz";
    sha256 = "sha256:06jzngg5jm1f81sc4xfskvvgjy5bblz51xpl788mnps1wrkykfhp";
  }) {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "gamescope-session-steam";
  version = "0.1.0";

  src = pkgs.fetchgit {
    url = "https://github.com/ChimeraOS/gamescope-session-steam";
    rev = "1a3fdb7fa15a4bba7204bef69702b7a10a297828";
    sha256 = "sha256-jlrqb4GReTETCke5klrkRFIafKy/k/icNi7CmgziuLk=";
  };

  buildInputs = [];

  buildPhase = "true";  # Do nothing in build phase
  configurePhase = "true";  # Do nothing in configure phase
  installPhase = ''
    mkdir -p $out
    cp -r $src/usr $out/usr  # Copy the 'usr' directory from the source to the output
  '';
}

