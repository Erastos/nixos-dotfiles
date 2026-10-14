{ inputs, ...}:
let
  system = "x86_64-linux";
  overlays = builtins.map (name: import (../overlays + "/${name}"))
    (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
      (builtins.attrNames (builtins.readDir ../overlays)));
  unstablePkgs = import ../lib/mkUnstablePkgs.nix { inherit inputs system; };
  unstableOverlay = _final: _prev: {
    unstable = unstablePkgs;
    inherit (unstablePkgs) openclaw openclawPackages;
  };
in
{
  den.default.nixos.nixpkgs.overlays = [ unstableOverlay inputs.proton-cachyos.overlays.default inputs.cachyos-kernel.overlays.pinned ] ++ overlays;
  den.default.homeManager.nixpkgs.overlays = [ unstableOverlay inputs.llm-agents.overlays.shared-nixpkgs ] ++ overlays;
}
