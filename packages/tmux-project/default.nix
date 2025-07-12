{ stdenv, ... }:
stdenv.mkDerivation {
  name = "tmux-project";
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin
    cp ./tmux-project $out/bin/
  '';
}
