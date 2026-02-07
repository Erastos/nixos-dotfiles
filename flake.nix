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
    # go-overlay = {
    #   url = "github:purpleclay/go-overlay";
    # };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, claude-desktop, ...}:
    let
      system = "x86_64-linux";
      overlays = builtins.map (name: import (./overlays + "/${name}"))
        (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
          (builtins.attrNames (builtins.readDir ./overlays)));
      unstable = import nixpkgs-unstable { inherit system overlays; config.allowUnfree = true; };
      mkHost = import ./lib/mkHost.nix {
        inherit nixpkgs home-manager sops-nix unstable claude-desktop overlays;
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
          netscape.system.desktop.plasma.enable = false;
          netscape.system.desktop.niri.enable = true;
        };
        homeConfig = {
          netscape.home.colors.enable = true;
          netscape.home.colors.scheme = "cyberpunk-neon";
          netscape.home.terminals.foot.enable = true;
          netscape.home.wm.niri.enable = true;
          netscape.home.wm.waybar.enable = true;
          netscape.home.theming.enable = true;
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
        };
        homeConfig = {};
        hostPackages = ./hosts/Neo.nix;
      };
    };
}
