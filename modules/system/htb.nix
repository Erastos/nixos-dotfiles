{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.htb;

  updateScript = pkgs.writeShellScript "htb-update-hosts" ''
    set -euo pipefail

    HOSTS_FILE="/var/lib/htb/hosts"
    API_URL="${cfg.url}"
    API_KEY="$(cat /run/secrets/htb-api-key)"

    # Fetch active machine info from HTB API
    echo "Fetching HTB active machine info..."
    response=$(${pkgs.curl}/bin/curl -s -H "Authorization: Bearer $API_KEY" "$API_URL" || echo "{}")

    # Check if response is empty or error
    if [[ -z "$response" || "$response" == "{}" ]]; then
      echo "No active machine found or API error"
      echo "# No active HTB machines" > "$HOSTS_FILE"
      exit 0
    fi

    # Parse JSON - handle both single object and array responses
    # Try to parse as single machine first
    ip=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.info.ip // .ip // empty' 2>/dev/null || true)
    name=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.info.name // .info.name // empty' 2>/dev/null || true)

    # If single machine parsing failed, try array format
    if [[ -z "$ip" ]]; then
      # Parse as array and get all machines
      machines=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.[] | "\(.ip // .info.ip) \(.name // .info.name)"' 2>/dev/null || true)

      if [[ -z "$machines" ]]; then
        echo "Could not parse API response. Response:"
        echo "$response" | ${pkgs.jq}/bin/jq '.' 2>/dev/null || echo "$response"
        echo "# Failed to parse HTB API response" > "$HOSTS_FILE"
        exit 1
      fi

      # Write hosts file with all machines
      {
        echo "# HTB Active Machines"
        echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""

        # Add all machines
        echo "$machines" | while read -r machine_ip machine_name; do
          if [[ -n "$machine_ip" && -n "$machine_name" ]]; then
            echo "$machine_ip $machine_name${cfg.domainSuffix} $machine_name"
          fi
        done

        # Handle active.htb alias
        ${if cfg.activeMachine != null then ''
          # Use specified active machine
          active_ip=$(echo "$machines" | grep -E " ${cfg.activeMachine}$" | awk '{print $1}' || true)
          if [[ -n "$active_ip" ]]; then
            echo "$active_ip active${cfg.domainSuffix}"
          else
            echo "# Warning: activeMachine '${cfg.activeMachine}' not found in API response"
          fi
        '' else ''
          # Use first machine as active
          first_ip=$(echo "$machines" | head -n1 | awk '{print $1}')
          if [[ -n "$first_ip" ]]; then
            echo "$first_ip active${cfg.domainSuffix}"
          fi
        ''}
      } > "$HOSTS_FILE"
    else
      # Single machine response
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

    # Reload NetworkManager to pick up DNS changes
    if ${pkgs.systemd}/bin/systemctl is-active NetworkManager >/dev/null 2>&1; then
      echo "Reloading NetworkManager..."
      ${pkgs.systemd}/bin/systemctl reload NetworkManager || true
    fi

    echo "HTB hosts file updated successfully"
  '';
in
{
  options.netscape.system.htb = {
    enable = lib.mkEnableOption "HTB dynamic DNS resolution";

    apiKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        HTB API authentication token.
        Managed via sops-nix - read from /run/secrets/htb-api-key at runtime.
      '';
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "https://labs.hackthebox.com/api/v4/machine/active";
      description = "HTB API endpoint for active machines";
    };

    updateInterval = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "How often to check for HTB machine updates (systemd time format)";
    };

    domainSuffix = lib.mkOption {
      type = lib.types.str;
      default = ".htb";
      description = "Domain suffix for HTB machine hostnames";
    };

    activeMachine = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Specify which machine should be aliased as "active.htb".
        If null, uses the first/only active machine from the API.
        If set to a machine name, active.htb will point to that machine's IP.
      '';
      example = "example";
    };
  };

  config = lib.mkIf cfg.enable {
    # Configure sops secret for HTB API key
    sops.secrets."htb-api-key" = {
      sopsFile = ../../secrets/secrets.yaml;
      key = "${config.netscape.systemName}/htb/api_key";
      mode = "0400";
      owner = "root";
      group = "root";
    };

    # Configure NetworkManager to use dnsmasq for local DNS resolution
    # This provides dynamic DNS without needing systemd-resolved
    networking.networkmanager.dns = "dnsmasq";

    # Configure dnsmasq to read HTB hosts file
    environment.etc."NetworkManager/dnsmasq.d/htb.conf".text = ''
      # Read HTB hosts from /var/lib/htb/hosts
      addn-hosts=/var/lib/htb/hosts
    '';

    # Create directory and initial hosts file
    systemd.tmpfiles.rules = [
      "d /var/lib/htb 0755 root root -"
      "f /var/lib/htb/hosts 0644 root root - # HTB hosts file\n"
    ];

    # Service to update HTB hosts
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

    # Timer to periodically update HTB hosts
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
}
