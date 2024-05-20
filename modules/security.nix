{ config, lib, pkgs, ...}:

{
  networking.hosts = {
    "10.129.197.25" = [ "devvortex.htb" ];
  };
}
