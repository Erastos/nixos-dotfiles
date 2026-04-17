{ ... }:
{
  nixosModuleLib.dropbox = { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [ dropbox dropbox-cli ];

    systemd.user.services.dropbox = {
      name = "dropbox";
      description = "Dropbox File Sync Daemon";
      enable = true;
      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.dropbox}/bin/dropbox";
        Restart = "on-failure";
        RestartSec = 5;
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
  };
}
