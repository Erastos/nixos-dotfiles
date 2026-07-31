{ pkgs, ... }: {
  programs.wireshark.enable = true;
  users.users.netscape.extraGroups = ["wireshark"];
  environment.systemPackages = [ pkgs.android-tools ];
}
