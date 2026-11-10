# Host-only DNS routing and public CA trust for the local kind cluster.
# Keep Tailscale accept-dns enabled; update these split domains if tailnet DNS changes.
{ config, lib, ... }:
let
  cfg = config.netscape.system.local-kubernetes;
in
{
  options.netscape.system.local-kubernetes.enable =
    lib.mkEnableOption "host DNS and CA trust for the kubernetes-start development cluster";

  config = lib.mkIf cfg.enable {
    networking.resolvconf.useLocalResolver = true;

    environment.etc."NetworkManager/dnsmasq.d/kubernetes-start.conf".text = ''
      server=/netsca.pe/100.100.100.100
      server=/ts.net/100.100.100.100
      server=/cluster.test/127.0.0.1#53535
    '';

    # This is the public root certificate only. Its private key remains outside
    # the flake and Nix store in kubernetes-start's ignored, mode-0700 state.
    security.pki.certificateFiles = [ ../../certs/kubernetes-start-rootCA.pem ];
  };
}
