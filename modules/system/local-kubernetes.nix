# Host-only DNS routing, public CA trust, and a fixed Kind Docker bridge.
# Keep Tailscale accept-dns enabled; update these split domains if tailnet DNS changes.
{ config, lib, pkgs, ... }:
let
  cfg = config.netscape.system.local-kubernetes;
  docker = "${config.virtualisation.docker.package}/bin/docker";
  jq = "${pkgs.jq}/bin/jq";
  kindIPv4Subnet = "172.30.0.0/16";
  kindIPv6Subnet = "fc00:f853:ccd:e793::/64";
  kindMTU = "1500";
in
{
  options.netscape.system.local-kubernetes = {
    enable = lib.mkEnableOption "host DNS, CA trust, and Docker network for the kubernetes-start development cluster";
    bridgeName = lib.mkOption {
      type = lib.types.str;
      default = "br-kind";
      description = "Stable Linux bridge interface for the Kind Docker network.";
    };
    podSubnet = lib.mkOption {
      type = lib.types.str;
      default = "10.244.0.0/16";
      description = "IPv4 pod subnet used by kubernetes-start and the scoped reverse-path filter exception.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "local-kubernetes requires virtualisation.docker.enable.";
      }
    ];

    networking.resolvconf.useLocalResolver = true;

    environment.etc."NetworkManager/dnsmasq.d/kubernetes-start.conf".text = ''
      server=/netsca.pe/100.100.100.100
      server=/ts.net/100.100.100.100
      server=/cluster.test/127.0.0.1#53535
    '';

    # Skip strict rpfilter for pod sources entering the fixed bridge: pod peers,
    # plus the Kind IPv4 network (not just the control plane's dynamic /32).
    networking.firewall.extraCommands = ''
      iptables -w -t mangle -I nixos-fw-rpfilter 1 -i ${lib.escapeShellArg cfg.bridgeName} -s ${lib.escapeShellArg cfg.podSubnet} -d ${lib.escapeShellArg cfg.podSubnet} -m comment --comment kind-local-dev-pods -j RETURN
      iptables -w -t mangle -I nixos-fw-rpfilter 1 -i ${lib.escapeShellArg cfg.bridgeName} -s ${lib.escapeShellArg cfg.podSubnet} -d ${lib.escapeShellArg kindIPv4Subnet} -m comment --comment kind-local-dev-network -j RETURN
    '';

    # Never replace the live network: its containers must be migrated separately.
    systemd.services.kind-docker-network = {
      description = "Ensure the Kind Docker network has a fixed bridge";
      wantedBy = [ "multi-user.target" ];
      requires = [ "docker.service" ];
      after = [ "docker.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail
        if ${docker} network inspect kind >/dev/null 2>&1; then
          if ! ${docker} network inspect kind | ${jq} -e \
            --arg bridge ${lib.escapeShellArg cfg.bridgeName} \
            --arg ipv4 ${lib.escapeShellArg kindIPv4Subnet} \
            --arg ipv6 ${lib.escapeShellArg kindIPv6Subnet} \
            --arg mtu ${lib.escapeShellArg kindMTU} \
            '.[0] | .Driver == "bridge" and .EnableIPv4 == true and .EnableIPv6 == true
              and ([.IPAM.Config[].Subnet] | sort == ([$ipv4, $ipv6] | sort))
              and .Options["com.docker.network.bridge.name"] == $bridge
              and .Options["com.docker.network.bridge.enable_ip_masquerade"] == "true"
              and .Options["com.docker.network.driver.mtu"] == $mtu' >/dev/null; then
            echo "Existing Docker network kind is incompatible with the declared bridge/IPAM settings." >&2
            echo "Migrate the Kind cluster and network manually; this unit will not delete or change them." >&2
            exit 1
          fi
        else
          ${docker} network create --driver bridge --ipv6 \
            --subnet ${lib.escapeShellArg kindIPv4Subnet} \
            --subnet ${lib.escapeShellArg kindIPv6Subnet} \
            --opt ${lib.escapeShellArg "com.docker.network.bridge.name=${cfg.bridgeName}"} \
            --opt com.docker.network.bridge.enable_ip_masquerade=true \
            --opt com.docker.network.driver.mtu=${kindMTU} kind
        fi
      '';
    };

    # This is the public root certificate only. Its private key remains outside
    # the flake and Nix store in kubernetes-start's ignored, mode-0700 state.
    security.pki.certificateFiles = [ ../../certs/kubernetes-start-rootCA.pem ];
  };
}
