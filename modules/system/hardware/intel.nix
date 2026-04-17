{ ... }:
{
  nixosModuleLib.intel = {
    services.xserver.videoDrivers = [ "modesetting" ];
    hardware.graphics.enable = true;
  };
}
