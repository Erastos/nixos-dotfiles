{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.virtualisation;
in
{
  options.netscape.system.virtualisation = {
    vmware.enable = lib.mkEnableOption "Enale VMware Host Virtualisation";
  };

  config = lib.mkIf cfg.vmware.enable {
    virtualisation.vmware.host.enable = true;
    environment.systemPackages = with pkgs; [
      open-vm-tools
    ];
  };
}
