{ ... }:
{
  nixosModuleLib.touchpad = {
    services.libinput.enable = true;
  };
}
