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

      cp -r themes/Bluecurve themes/Bluecurve-Classic-RH8 themes/Bluecurve-Classic-RH9 $out/share/themes/

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
