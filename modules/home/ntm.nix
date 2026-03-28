{ config, lib, ... }:

let
  cfg = config.netscape.home.ntm;
in
{
  options.netscape.home.ntm = {
    enable = lib.mkEnableOption "NTM (Named Tmux Manager) configuration" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."ntm/config.toml".text = ''
      # NTM Configuration (managed by NixOS)
      projects_base = "/home/netscape/projects"
    '';

    programs.zsh.initContent = ''
      eval "$(ntm shell zsh)"
    '';
  };
}
