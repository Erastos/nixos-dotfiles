{ lib, config, inputs, ... }:
let
  mkPkgs = import ../_lib/mkPkgs.nix;
in
{
  config.flake.nixosConfigurations = lib.mapAttrs (
    _name: { module }:
    inputs.nixpkgs.lib.nixosSystem {
      pkgs = mkPkgs inputs "x86_64-linux";
      specialArgs = { inherit (inputs) claude-desktop; };
      modules = [
        inputs.sops-nix.nixosModules.sops
        inputs.hermes-agent.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit (inputs) claude-desktop; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        module
      ];
    }
  ) config.configurations.nixos;
}
