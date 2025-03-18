{ stdenv, ... }:
stdenv.mkDerivation {
  name = "git-tools";
  src = ./git-tools;
  installPhase = ''
    mkdir -p $out/bin
    cp ./* $out/bin/
  '';
}
