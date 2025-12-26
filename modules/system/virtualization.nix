{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.virtualisation;
in
{
  options.netscape.system.virtualisation = {
    vmware.enable = lib.mkEnableOption "Enale VMware Host Virtualisation";
    qemu.enable = lib.mkEnableOption "Enale Qemu Host Virtualisation";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.vmware.enable {
      virtualisation.vmware.host.enable = true;
      environment.systemPackages = with pkgs; [
        open-vm-tools
      ];
    })

    (lib.mkIf cfg.qemu.enable {
      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = ["netscape"];
      virtualisation.libvirtd.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
    })
  ];
}
