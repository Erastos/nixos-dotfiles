{ config, lib, nixpkgs, inputs, unstable, specialArgs, options, modulesPath }:

nixpkgs.stdenv.mkDerivation rec {
  name = "rofi-themes";
  src = nixpkgs.fetchFromGitHub {
    owner = "lr-tech";
    repo = "rofi-themes-collection";
    rev = "master";
    hash = "sha256-uNgsOaHeuTMyKbG6A4T5oHGmoONH0Ae3CbKKHFjyrH4=";
  };
  # nativeBuildInputs = [
  #   rofi
  # ];

  installPhase = ''
  mkdir -p $out/share/rofi/themes
  cp -r $src/themes $out/share/rofi/themes
  '';
}
