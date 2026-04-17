{ ... }:
{
  nixosModuleLib.qemu = { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      virtio-win
      dnsmasq
    ];

    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [ "netscape" ];
    users.groups.kvm.members = [ "netscape" ];
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
  };
}
