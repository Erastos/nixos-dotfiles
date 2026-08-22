# modules/system/bloodhound-ce.nix
{ config, lib, ... }:

let
  cfg = config.netscape.system.bloodhound-ce;

  # Both hosts use docker (netscape.system.services.docker.enable = true).
  # Branch on the services flag so the module also works if a host switches to podman.
  backend =
    if config.netscape.system.services.podman.enable then "podman" else "docker";
  runtimePkg =
    if backend == "podman" then config.virtualisation.podman.package
    else config.virtualisation.docker.package;

  net = "bloodhound-net";

  # Generated systemd unit names: ${backend}-${name}
  appDbSvc   = "${backend}-bloodhound-app-db";
  graphDbSvc = "${backend}-bloodhound-graph-db";
  appSvc     = "${backend}-bloodhound";
in
{
  options.netscape.system.bloodhound-ce = {
    enable = lib.mkEnableOption "BloodHound Community Edition web app (postgres + neo4j + app via OCI containers)";

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Start the BloodHound CE stack automatically at boot. Defaults to false
        (on-demand): start with `systemctl start bloodhound-ce.target`,
        stop with `systemctl stop bloodhound-ce.target`.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Host port (bound to 127.0.0.1) for the BloodHound web UI.";
    };

    exposeDbPorts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Expose Neo4j bolt (7687) and browser (7474) on 127.0.0.1 for direct Cypher queries.";
    };

    imageTag = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "Tag for the specterops/bloodhound image (pin e.g. \"5.13.0\" for reproducibility).";
    };

    dbPassword = lib.mkOption {
      type = lib.types.str;
      default = "bloodhoundcommunityedition";
      description = "PostgreSQL app-DB password (matches upstream compose default).";
    };

    neo4jPassword = lib.mkOption {
      type = lib.types.str;
      default = "bloodhoundcommunityedition";
      description = "Neo4j password (matches upstream compose default).";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.netscape.system.services.docker.enable
          || config.netscape.system.services.podman.enable;
        message = "netscape.system.bloodhound-ce requires netscape.system.services.docker.enable (or podman) to be true.";
      }
    ];

    virtualisation.oci-containers.backend = backend;

    virtualisation.oci-containers.containers = {
      bloodhound-app-db = {
        image = "docker.io/library/postgres:18";
        autoStart = false;
        environment = {
          PGUSER = "bloodhound";
          POSTGRES_USER = "bloodhound";
          POSTGRES_PASSWORD = cfg.dbPassword;
          POSTGRES_DB = "bloodhound";
        };
        volumes = [ "bloodhound-postgres-data:/var/lib/postgresql" ];
        networks = [ net ];
      };

      bloodhound-graph-db = {
        # BloodHound CE requires Neo4j 4.4.x — do NOT upgrade to 5.x.
        image = "docker.io/library/neo4j:4.4.42";
        autoStart = false;
        environment = {
          NEO4J_AUTH = "neo4j/${cfg.neo4jPassword}";
          NEO4J_dbms_allow__upgrade = "true";
        };
        ports = lib.optionals cfg.exposeDbPorts [
          "127.0.0.1:7687:7687"
          "127.0.0.1:7474:7474"
        ];
        volumes = [ "bloodhound-neo4j-data:/data" ];
        networks = [ net ];
      };

      bloodhound = {
        image = "docker.io/specterops/bloodhound:${cfg.imageTag}";
        autoStart = false;
        dependsOn = [ "bloodhound-app-db" "bloodhound-graph-db" ];
        environment = {
          bhe_graph_driver = "neo4j";
          bhe_database_connection =
            "user=bloodhound password=${cfg.dbPassword} dbname=bloodhound host=bloodhound-app-db";
          bhe_neo4j_connection =
            "neo4j://neo4j:${cfg.neo4jPassword}@bloodhound-graph-db:7687/";
          bhe_recreate_default_admin = "false";
          bhe_disable_cypher_complexity_limit = "false";
          bhe_enable_cypher_mutations = "false";
          bhe_graph_query_memory_limit = "2";
        };
        ports = [ "127.0.0.1:${toString cfg.port}:8080" ];
        networks = [ net ];
      };
    };

    # Create the user-defined bridge network (idempotent). Docker's embedded DNS
    # resolves the container names above only on user-defined networks.
    systemd.services.bloodhound-ce-network = {
      description = "Ensure OCI network for BloodHound CE";
      after = [ "${backend}.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      # `script` runs via bash so `|| true` makes creation idempotent
      # (network already exists on subsequent starts).
      script = ''
        ${runtimePkg}/bin/${backend} network create ${net} 2>/dev/null || true
      '';
    };

    # Group all three container units under one target for one-command start/stop,
    # and make each require the network-creation service. These merge with the
    # service definitions generated by virtualisation.oci-containers.
    systemd.services.${appDbSvc} = {
      wantedBy = [ "bloodhound-ce.target" ];
      after = [ "bloodhound-ce-network.service" ];
      requires = [ "bloodhound-ce-network.service" ];
    };
    systemd.services.${graphDbSvc} = {
      wantedBy = [ "bloodhound-ce.target" ];
      after = [ "bloodhound-ce-network.service" ];
      requires = [ "bloodhound-ce-network.service" ];
    };
    systemd.services.${appSvc} = {
      wantedBy = [ "bloodhound-ce.target" ];
      after = [ "bloodhound-ce-network.service" ];
      requires = [ "bloodhound-ce-network.service" ];
    };

    systemd.targets.bloodhound-ce = {
      description = "BloodHound Community Edition stack (app-db + graph-db + app)";
      wantedBy = lib.optional cfg.autoStart "multi-user.target";
    };
  };
}
