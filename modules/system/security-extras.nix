{ pkgs, ... }: {
  programs.wireshark.enable = true;
  users.users.netscape.extraGroups = ["wireshark"];
  environment.systemPackages = [ pkgs.android-tools pkgs.sharphound ];
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
