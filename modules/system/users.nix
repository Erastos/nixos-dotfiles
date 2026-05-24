{ pkgs, ... }: {
  programs.zsh.enable              = true;
  users.users.netscape.extraGroups = [ "dialout" ];
  users.users.netscape.shell       = pkgs.zsh;
}
