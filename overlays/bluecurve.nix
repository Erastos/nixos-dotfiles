final: prev: {
  bluecurve = prev.stdenv.mkDerivation {
    pname = "bluecurve";
    version = "0-unstable-2026-06-25";

    src = prev.fetchFromGitHub {
      owner = "neeeeow";
      repo = "Bluecurve";
      rev = "013ba225e78d9767b274ac6f16a67cb19f0673c6";
      hash = "sha256-xSAfryAPaNXij+lDI5M2k07oVH6F/MOxRaX3jHI3TV4=";
    };

    nativeBuildInputs = [ (prev.python3.withPackages (p: [ p.lxml ])) ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/themes $out/share/icons $out/share/fonts $out/share/wallpapers

      # Bluecurve-Dark: navy dark recolor of the default scheme, derived by
      # substituting the @define-color palettes (gtk-4.0 files are symlinks
      # into gtk-3.0, so patching gtk-3.0 covers GTK4 too).
      cp -r themes/Bluecurve themes/Bluecurve-Dark

      sed -i \
        -e 's|@define-color theme_fg_color #000000;|@define-color theme_fg_color #d3d7cf;|' \
        -e 's|@define-color theme_text_color #000000;|@define-color theme_text_color #d3d7cf;|' \
        -e 's|@define-color theme_bg_color #e6e6e6;|@define-color theme_bg_color #1f2a3d;|' \
        -e 's|@define-color prelight_color #f5f5f5;|@define-color prelight_color #374b6e;|' \
        -e 's|@define-color bg_active_color #cccccc;|@define-color bg_active_color #2e3d5c;|' \
        -e 's|@define-color theme_base_color #ffffff;|@define-color theme_base_color #182236;|' \
        -e 's|@define-color insensitive_bg_color #eeeeee;|@define-color insensitive_bg_color #2a3244;|' \
        -e 's|@define-color insensitive_fg_color #777777;|@define-color insensitive_fg_color #888a85;|' \
        -e 's|@define-color insensitive_base_color #f0f0f0;|@define-color insensitive_base_color #1d2739;|' \
        -e 's|@define-color link_color #0000ee;|@define-color link_color #7a9ede;|' \
        -e 's|@define-color link_visited_color #551a8b;|@define-color link_visited_color #ad7fa8;|' \
        -e 's|@define-color theme_tooltip_bg_color #ffffbf;|@define-color theme_tooltip_bg_color #2e3d5c;|' \
        -e 's|@define-color theme_tooltip_fg_color #000000;|@define-color theme_tooltip_fg_color #ffffff;|' \
        -e 's|@define-color theme_tooltip_border_color #000000;|@define-color theme_tooltip_border_color #777777;|' \
        themes/Bluecurve-Dark/gtk-3.0/gtk.css

      sed -i \
        -e 's|@define-color box_shadow_light_color #ffffff;|@define-color box_shadow_light_color #374b6e;|' \
        -e 's|@define-color frame_light_color #ffffff;|@define-color frame_light_color #2e3d5c;|' \
        -e 's|@define-color button_icon_hover_color #000000;|@define-color button_icon_hover_color #d3d7cf;|' \
        -e 's|@define-color grab_light_color #ffffff;|@define-color grab_light_color #374b6e;|' \
        -e 's|@define-color check_background_color #ffffff;|@define-color check_background_color #182236;|' \
        -e 's|@define-color menu_check_color #000000;|@define-color menu_check_color #d3d7cf;|' \
        themes/Bluecurve-Dark/gtk-3.0/shade.css

      sed -i \
        -e 's|^Name=Bluecurve$|Name=Bluecurve-Dark|' \
        -e 's|^GtkTheme=Bluecurve$|GtkTheme=Bluecurve-Dark|' \
        themes/Bluecurve-Dark/index.theme

      cp -r themes/Bluecurve themes/Bluecurve-Classic-RH8 themes/Bluecurve-Classic-RH9 themes/Bluecurve-Dark $out/share/themes/

      # Bluecurve icon themes; symlink.py materializes the symbolic icon names
      # (same invocation as the repo's CMakeLists.txt, minus gtk-update-icon-cache)
      cp -r icons/icon-set icon-set-build
      python3 icons/symlink.py icons/icon-xml icon-set-build/Bluecurve
      cp -r icon-set-build/Bluecurve icon-set-build/Bluecurve-inverse \
            icon-set-build/LBluecurve icon-set-build/LBluecurve-inverse $out/share/icons/

      cp fonts/*.ttf $out/share/fonts/
      cp wallpapers/*.png $out/share/wallpapers/

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Red Hat Bluecurve GTK 3/4 theme, icons, Luxi fonts, and original wallpapers";
      homepage = "https://github.com/neeeeow/Bluecurve";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };
}
