{ ... }:
{
  nixosModuleLib.bluetooth = {
    hardware.bluetooth.enable = true;
  };
}
