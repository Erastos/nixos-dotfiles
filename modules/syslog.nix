{ config, lib, pkgs, ...}:

{
  services.syslogd = {
    enable = true;
    enableNetworkInput = true;
  };
}

