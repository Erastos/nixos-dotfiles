{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.netscape.packages.devops;
in
{
  options.netscape.packages.devops = {
    enable = lib.mkEnableOption "DevOps and container tools" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Containers/DevOps
      kubectl
      unstable.k9s
      kubernetes-helm
      skopeo
      ansible
      terraform
      jq
      packer
      talosctl
      sops
      age
      ssh-to-age

      # Nix / NixOS
      cntr
    ] ++ lib.optionals osConfig.netscape.system.services.docker.enable [
      docker-compose
    ];
  };
}
