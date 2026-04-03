{
  description = "Netscape's Config Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.home-manager.follows = "home-manager";
    };
    devenv.url = "github:cachix/devenv";
    nixpkgs-python = {
      url = "github:cachix/nixpkgs-python";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
    # go-overlay = {
    #   url = "github:purpleclay/go-overlay";
    # };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, claude-desktop, nix-openclaw, flake-utils, devenv, nixpkgs-python, ...}:
    let
      system = "x86_64-linux";
      overlays = builtins.map (name: import (./overlays + "/${name}"))
        (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
          (builtins.attrNames (builtins.readDir ./overlays)));
      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      openclawOverlay = final: prev: let
        openclawPkgs = import nix-openclaw.inputs.nixpkgs {
          inherit system;
          overlays = [ nix-openclaw.overlays.default ];
        };
        patchedGateway = openclawPkgs.openclawPackages.openclaw-gateway.overrideAttrs (old: {
          installPhase = ''
            ${old.installPhase}
            # Fix upstream bug: copy missing plugin manifests to dist/extensions
            for manifest in $out/lib/openclaw/node_modules/.pnpm/openclaw@*/node_modules/openclaw/extensions/*/openclaw.plugin.json; do
              ext_name=$(basename $(dirname "$manifest"))
              target="$out/lib/openclaw/dist/extensions/$ext_name/openclaw.plugin.json"
              if [ -d "$out/lib/openclaw/dist/extensions/$ext_name" ] && [ ! -f "$target" ]; then
                cp "$manifest" "$target"
              fi
            done
          '';
        });
      in {
        # Rebuild the bundle with the patched gateway
        openclaw = final.buildEnv {
          name = openclawPkgs.openclaw.name;
          paths = [ patchedGateway openclawPkgs.openclaw-tools ];
          pathsToLink = [ "/bin" ];
          inherit (openclawPkgs.openclaw) meta;
        };
        openclawPackages = openclawPkgs.openclawPackages // { openclaw-gateway = patchedGateway; };
      };
      allOverlays = [ unstableOverlay openclawOverlay ] ++ overlays;
      mkHost = import ./lib/mkHost.nix {
        inherit nixpkgs home-manager sops-nix claude-desktop nix-openclaw;
        overlays = allOverlays;
      };
    in
    {
      nixosConfigurations.Trinity = mkHost {
        name = "Trinity";
        hostType = "desktop";
        hardware = ./hardware/Trinity.nix;
        systemConfig = {
          netscape.system.networking.firewall.http.enable = true;
          netscape.system.htb.enable = true;
          netscape.system.virtualisation.vmware.enable = true;
          netscape.system.virtualisation.qemu.enable = true;
          netscape.system.desktop.plasma.enable = false;
          netscape.system.desktop.niri.enable = true;
          netscape.system.services.docker.enable = true;
          netscape.system.openclaw.enable = true;
        };
        homeConfig = {
          netscape.home.colors.enable = true;
          netscape.home.colors.scheme = "cyberpunk-neon";
          netscape.home.terminals.foot.enable = true;
          netscape.home.wm.niri.enable = true;
          netscape.home.wm.waybar.enable = true;
          netscape.home.theming.enable = true;
          netscape.home.openclaw.enable = true;
          netscape.home.openclaw.discord.enable = true;
          netscape.home.openclaw.discord.allowedUsers = [ "472461058855010334" ];
        };
        hostPackages = ./hosts/Trinity.nix;
      };

      nixosConfigurations.Neo = mkHost {
        name = "Neo";
        hostType = "laptop";
        hardware = ./hardware/Neo.nix;
        systemConfig = {
          netscape.system.networking.firewall.http.enable = true;
          netscape.system.htb.enable = true;
          netscape.system.virtualisation.qemu.enable = true;
          netscape.system.services.docker.enable = true;
        };
        homeConfig = {
          netscape.home.wm.waybar.enable = true;
          netscape.home.theming.enable = true;
          netscape.home.theming.gtkTheme = "Tokyonight-Dark";
        };
        hostPackages = ./hosts/Neo.nix;
      };
    }
    //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = allOverlays;
          config.allowUnfree = true;
        };
      in {
        devShells = import ./shells { inherit self pkgs devenv system nixpkgs-python; };
      }
    );
}
