{ den, ... }: {
  den.aspects.netscape = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      den.aspects.shared-hm
    ];

    homeManager.netscape.home.theming.enable = true;
  };

  den.aspects."netscape@Neo".homeManager = { pkgs, ... }: {
    netscape.home.wm.river.enable  = true;
    netscape.home.wm.waybar.enable = true;
    netscape.home.theming.gtkTheme = "Tokyonight-Dark";
    netscape.home.editors.theme    = "gruvbox-material";
    home.packages = with pkgs; [ acpi dmenu wl-clipboard eslint_d ];
  };

  den.aspects."netscape@Trinity".homeManager = { config, ... }: {
    netscape.home.colors.enable = true;
    netscape.home.colors.scheme =
      if config.netscape.home.wm.niri.profile == "enterprise-2000"
      then "enterprise-2000-dark"
      else "cyberpunk-neon";
    netscape.home.terminals.foot.enable = true;
    netscape.home.wm.niri.enable        = true;
    # Change this value to switch between the cyberpunk and Bluecurve rice.
    netscape.home.wm.niri.profile = "enterprise-2000";
  };
}
