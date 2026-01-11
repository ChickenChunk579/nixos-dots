{
  lib,
  pkgs
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "pywal-spicetify";
  version = "0.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "jhideki";
    repo = "pywal-spicetify";
    rev = "0.1.1";
    sha256 = "sha256-iyy1icLIvHo3MfkqGeQZ9pGnjxduqOK/EzJILTQ1I/4=";
  };

  cargoHash = "sha256-vzfaIabU9Bj8Ow6Q2q7lCKJpV1Gt4C7uaYENrrhIMwU=";
  nativeBuildInputs = [ pkgs.rustPlatform.bindgenHook ];

  buildInputs = [
    pkgs.pywal
    pkgs.spicetify-cli
  ];


  doCheck = false;

  meta = with pkgs.lib; {
    description = "Apply wal colors to spicetify";
    homepage = "https://github.com/jhideki/pywal-spicetify";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
