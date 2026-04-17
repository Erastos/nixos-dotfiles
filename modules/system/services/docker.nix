{ ... }:
{
  nixosModuleLib.docker = {
    users.users.netscape.extraGroups = [ "docker" ];
    virtualisation.docker.enable = true;
  };
}
