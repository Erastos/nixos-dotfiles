{ ... }:
{
  nixosModuleLib.devopsPkgs = { pkgs, ... }:
  {
    home-manager.users.netscape = {
      home.packages = with pkgs; [
        kubectl
        unstable.k9s
        kubernetes-helm
        skopeo
        ansible
        unstable.terraform
        jq
        packer
        talosctl
        sops
        age
        ssh-to-age
        docker-compose
        cntr
      ];
    };
  };
}
