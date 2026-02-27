{ pkgs, mkDevShell }: mkDevShell {
  name     = "devops";
  packages = with pkgs; [
    docker-compose kubectl k9s helm
    unstable.terraform ansible
    sops age skopeo jq yq-go
  ];
}
