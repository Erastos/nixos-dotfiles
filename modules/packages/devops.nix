{ config, lib, pkgs, unstable, ... }:

let
  cfg = config.netscape.packages.devops;
in
{
  options.netscape.packages.devops = {
    enable = lib.mkEnableOption "DevOps and container tools" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.netscape = {
      home.packages = with pkgs; [
        # Containers/DevOps
        kubectl
        unstable.k9s
        kubernetes-helm
        skopeo
        ansible
        podman
        terraform
        jq
        packer

        # Nix / NixOS
        cntr
      ];
    };
  };
}
