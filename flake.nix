{
  description = "Netscape's Config Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, ...}:
    let
      system = "x86_64-linux";
      overlays = builtins.map (name: import (./overlays + "/${name}"))
        (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
          (builtins.attrNames (builtins.readDir ./overlays)));
      pkgs = import nixpkgs { inherit system overlays; config.allowUnfree = true;};
      unstable = import nixpkgs-unstable { inherit system overlays; config.allowUnfree = true;};
    in
    {
      nixosConfigurations.Trinity = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {inherit unstable;};
        modules = [
          ./modules
          sops-nix.nixosModules.sops

          ./hardware/Trinity.nix

          ({ config, lib, pkgs, ... }: {
            system.stateVersion = "25.05";
            netscape.systemName = "Trinity";
            netscape.hostType = "desktop";
            netscape.system.networking.firewall.http.enable = true;
            netscape.system.htb.enable = true;
            netscape.system.virtualisation.vmware.enable = true;
          })

          home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = { inherit unstable; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.netscape = {
              imports = [
                ./modules/home
                ./hosts/Trinity.nix
                ({config, lib, ...}: {
                  netscape.home.colors.enable = true;
                  netscape.home.colors.scheme = "blue-matrix";
                  netscape.home.terminals.foot.enable = true;
                })
              ];
            };
          }
        ];
      };

      nixosConfigurations.Neo = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {inherit unstable;};
        modules = [
          ./modules
          sops-nix.nixosModules.sops

          ./hardware/Neo.nix

          ({ config, lib, pkgs, ... }: {
            system.stateVersion = "25.05";
            netscape.systemName = "Neo";
            netscape.hostType = "laptop";
            netscape.system.networking.firewall.http.enable = true;
            netscape.system.htb.enable = true;
            netscape.system.virtualisation.qemu.enable = true;
          })

          home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = { inherit unstable; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.netscape = {
              imports = [
                ./modules/home
                ./hosts/Neo.nix
              ];
            };
          }
        ];
      };
    };
}
