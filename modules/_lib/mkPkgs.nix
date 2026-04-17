inputs: system:
let
  overlayDir = ../_overlays;
  names = builtins.filter (n: builtins.match ".*\\.nix$" n != null)
    (builtins.attrNames (builtins.readDir overlayDir));
  fileOverlays = map (n: import (overlayDir + "/${n}")) names;
  unstableOverlay = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [ "openclaw-2026.4.12" ];
    };
  };
in
import inputs.nixpkgs {
  inherit system;
  config.allowUnfree = true;
  config.permittedInsecurePackages = [ "openclaw-2026.4.12" ];
  overlays = [ unstableOverlay ] ++ fileOverlays;
}
