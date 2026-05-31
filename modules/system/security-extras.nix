{ pkgs, ... }: {
  programs.wireshark.enable = true;
  environment.systemPackages = [ pkgs.android-tools ];
}
