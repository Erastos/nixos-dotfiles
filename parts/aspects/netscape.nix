{ den, lib, ... }: {
  den.aspects.netscape = {
    includes = [ den.batteries.define-user den.batteries.primary-user ];
  };

  den.aspects.netscape-linux = {
    includes = [ den.aspects.netscape den.aspects.shared-hm ];
  };

  den.aspects.netscape-neo = {
    includes = [ den.aspects.netscape-linux ];
    homeManager.imports = [
      ({ pkgs, ... }: {
        netscape.home.wm.river.enable       = true;
        netscape.home.wm.waybar.enable      = true;
        netscape.home.theming.enable        = true;
        netscape.home.theming.gtkTheme      = "Tokyonight-Dark";
        netscape.home.editors.theme         = "gruvbox-material";
        home.packages = with pkgs; [ pulsemixer acpi dmenu wl-clipboard eslint_d ];
      })
    ];
  };

  den.aspects.netscape-trinity = {
    includes = [ den.aspects.netscape-linux ];
    homeManager.imports = [
      ({ config, pkgs, ... }: {
        netscape.home.colors.enable         = true;
        netscape.home.colors.scheme         =
          if config.netscape.home.wm.niri.profile == "enterprise-2000"
          then "enterprise-2000"
          else "cyberpunk-neon";
        netscape.home.terminals.foot.enable = true;
        netscape.home.wm.niri.enable        = true;
        # Switch Trinity between the cyberpunk rice and the early-2000s
        # Bluecurve rice: change this one value and rebuild.
        netscape.home.wm.niri.profile       = "enterprise-2000";
        netscape.home.wm.waybar.enable      = true;
        netscape.home.theming.enable        = true;
        home.packages = with pkgs; [ git unstable.claude-code fzf ];
      })
    ];
  };
}
