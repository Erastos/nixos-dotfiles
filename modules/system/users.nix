{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.users;
in
{
  options.netscape.system.users = {
    enable = lib.mkEnableOption "user configuration (netscape user)" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    users.users.netscape = {
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" ];
      shell = pkgs.zsh;
    };
  };
}
