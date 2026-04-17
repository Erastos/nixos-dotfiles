{ ... }:
{
  nixosModuleLib.htb = { config, lib, pkgs, ... }:
  let
    cfg = config.netscape.system.htb;

    updateScript = pkgs.writeShellScript "htb-update-hosts" ''
      set -euo pipefail

      HOSTS_FILE="/var/lib/htb/hosts"
      API_URL="${cfg.url}"
      API_KEY="$(cat /run/secrets/htb-api-key)"

      echo "Fetching HTB active machine info..."
      response=$(${pkgs.curl}/bin/curl -s -H "Authorization: Bearer $API_KEY" "$API_URL" || echo "{}")

      if [[ -z "$response" || "$response" == "{}" ]]; then
        echo "No active machine found or API error"
        echo "# No active HTB machines" > "$HOSTS_FILE"
        exit 0
      fi

      ip=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.info.ip // .ip // empty' 2>/dev/null || true)
      name=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.info.name // .info.name // empty' 2>/dev/null || true)

      if [[ -z "$ip" ]]; then
        machines=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.[] | "\(.ip // .info.ip) \(.name // .info.name)"' 2>/dev/null || true)

        if [[ -z "$machines" ]]; then
          echo "Could not parse API response. Response:"
          echo "$response" | ${pkgs.jq}/bin/jq '.' 2>/dev/null || echo "$response"
          echo "# Failed to parse HTB API response" > "$HOSTS_FILE"
          exit 1
        fi

        {
          echo "# HTB Active Machines"
          echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
          echo ""

          echo "$machines" | while read -r machine_ip machine_name; do
            if [[ -n "$machine_ip" && -n "$machine_name" ]]; then
              echo "$machine_ip $machine_name${cfg.domainSuffix} $machine_name"
            fi
          done

          ${if cfg.activeMachine != null then ''
            active_ip=$(echo "$machines" | grep -E " ${cfg.activeMachine}$" | awk '{print $1}' || true)
            if [[ -n "$active_ip" ]]; then
              echo "$active_ip active${cfg.domainSuffix}"
            else
              echo "# Warning: activeMachine '${cfg.activeMachine}' not found in API response"
            fi
          '' else ''
            first_ip=$(echo "$machines" | head -n1 | awk '{print $1}')
            if [[ -n "$first_ip" ]]; then
              echo "$first_ip active${cfg.domainSuffix}"
            fi
          ''}
        } > "$HOSTS_FILE"
      else
        if [[ -n "$ip" && -n "$name" ]]; then
          {
            echo "# HTB Active Machine"
            echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "# Machine: $name ($ip)"
            echo ""
            echo "$ip $name${cfg.domainSuffix} $name active${cfg.domainSuffix}"
          } > "$HOSTS_FILE"
          echo "Updated HTB hosts: $ip $name${cfg.domainSuffix}"
        else
          echo "Invalid machine data: ip=$ip name=$name"
          echo "# Invalid HTB machine data" > "$HOSTS_FILE"
          exit 1
        fi
      fi

      if ${pkgs.systemd}/bin/systemctl is-active NetworkManager >/dev/null 2>&1; then
        echo "Reloading NetworkManager..."
        ${pkgs.systemd}/bin/systemctl reload NetworkManager || true
      fi

      echo "HTB hosts file updated successfully"
    '';
  in
  {
    options.netscape.system.htb = {
      apiKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "HTB API token — managed via sops-nix at /run/secrets/htb-api-key";
      };

      url = lib.mkOption {
        type = lib.types.str;
        default = "https://labs.hackthebox.com/api/v4/machine/active";
        description = "HTB API endpoint for active machines";
      };

      updateInterval = lib.mkOption {
        type = lib.types.str;
        default = "5min";
        description = "How often to poll the HTB API (systemd time format)";
      };

      domainSuffix = lib.mkOption {
        type = lib.types.str;
        default = ".htb";
        description = "Domain suffix for HTB machine hostnames";
      };

      activeMachine = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Machine to alias as active.htb; null = first machine";
        example = "example";
      };
    };

    config = {
      sops.secrets."htb-api-key" = {
        sopsFile = ../../secrets/secrets.yaml;
        key = "${config.networking.hostName}/htb/api_key";
        mode = "0400";
        owner = "root";
        group = "root";
      };

      networking.networkmanager.dns = "dnsmasq";

      environment.etc."NetworkManager/dnsmasq.d/htb.conf".text = ''
        addn-hosts=/var/lib/htb/hosts
      '';

      systemd.tmpfiles.rules = [
        "d /var/lib/htb 0755 root root -"
        "f /var/lib/htb/hosts 0644 root root - # HTB hosts file\n"
      ];

      systemd.services.htb-update = {
        description = "Update HTB machine hosts file";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${updateScript}";
          StandardOutput = "journal";
          StandardError = "journal";
        };
      };

      systemd.timers.htb-update = {
        description = "Update HTB hosts periodically";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1min";
          OnUnitActiveSec = cfg.updateInterval;
          Unit = "htb-update.service";
        };
      };
    };
  };
}
