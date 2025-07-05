{ config, lib, pkgs, ...}:

{
  il8n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };
}
