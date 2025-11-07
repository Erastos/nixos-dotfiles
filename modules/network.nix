{ config, lib, pkgs, ...}:

{
  assertions = [
    {
      assertion = config.systemName != null && config.systemName != "";
      message = "systemName must be set to a non-empty value";
    }
  ];

  networking.hostName = config.systemName;
  networking.networkmanager.enable = true;
}
