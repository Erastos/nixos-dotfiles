{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.virtualisation;
in
{
  options.netscape.system.virtualisation = {
    vmware.enable = lib.mkEnableOption "Enable VMware Host Virtualisation";
    qemu.enable = lib.mkEnableOption "Enable Qemu Host Virtualisation";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.vmware.enable {
      virtualisation.vmware.host.enable = true;
      environment.systemPackages = with pkgs; [
        open-vm-tools
      ];
    })

    (lib.mkIf cfg.qemu.enable {
      environment.systemPackages = with pkgs; [
        virt-manager
        virt-viewer
        virtio-win
        dnsmasq
      ];

      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = ["netscape"];
      users.groups.kvm.members = ["netscape"];
      virtualisation.spiceUSBRedirection.enable = true;
      virtualisation.libvirtd = {
        enable = true;

        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          vhostUserPackages = with pkgs; [ virtiofsd ];
        };
      };
    })
  ];
}
