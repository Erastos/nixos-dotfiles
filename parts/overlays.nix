{ inputs, ...}:
let
  system = "x86_64-linux";
  overlays = builtins.map (name: import (../overlays + "/${name}"))
    (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
      (builtins.attrNames (builtins.readDir ../overlays)));
  unstableOverlays = builtins.map (name: import (../overlays/unstable + "/${name}"))
    (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
      (builtins.attrNames (builtins.readDir ../overlays/unstable)));
  unstableOverlay = final: prev: let
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [ "openclaw-2026.4.12" ];
      overlays = [ inputs.nix-openclaw.overlays.default ] ++ unstableOverlays;
    };
  in {
    unstable = unstablePkgs;
    inherit (unstablePkgs) openclaw openclawPackages;
  };
in
{
  den.default.nixos.nixpkgs.overlays = [ unstableOverlay inputs.cachyos-kernel.overlays.pinned ] ++ overlays;
  den.default.homeManager.nixpkgs.overlays = [ unstableOverlay inputs.llm-agents.overlays.shared-nixpkgs ] ++ overlays;
}
