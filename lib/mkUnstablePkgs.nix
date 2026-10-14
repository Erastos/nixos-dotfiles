{ inputs, system }:
let
  overlays = builtins.map (name: import (../overlays/unstable + "/${name}"))
    (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
      (builtins.attrNames (builtins.readDir ../overlays/unstable)));
in
import inputs.nixpkgs-unstable {
  inherit system;
  config.allowUnfree = true;
  config.permittedInsecurePackages = [ "openclaw-2026.4.12" ];
  inherit overlays;
}
