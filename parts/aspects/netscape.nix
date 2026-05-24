{ den, lib, ... }: {
  den.aspects.netscape = {
    includes = [ den.batteries.define-user den.batteries.primary-user ];
  };

  den.aspects.netscape-linux = {
    includes = [ den.aspects.netscape den.aspects.shared-hm ];
  };

  den.aspects.netscape-trinity = {
    includes = [ den.aspects.netscape-linux ];
    homeManager.imports = [
      ({ pkgs, ... }: {
        netscape.home.colors.enable         = true;
        netscape.home.colors.scheme         = "cyberpunk-neon";
        netscape.home.terminals.foot.enable = true;
        netscape.home.wm.niri.enable        = true;
        netscape.home.wm.waybar.enable      = true;
        netscape.home.theming.enable        = true;
        home.packages = with pkgs; [ git unstable.claude-code fzf ];
      })
    ];
  };
}
