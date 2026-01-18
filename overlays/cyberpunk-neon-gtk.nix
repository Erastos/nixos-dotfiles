final: prev: {
  cyberpunk-neon-gtk-theme = prev.stdenv.mkDerivation {
    pname = "cyberpunk-neon-gtk-theme";
    version = "unstable-2024-01-01";

    src = prev.fetchFromGitHub {
      owner = "Roboron3042";
      repo = "Cyberpunk-Neon";
      rev = "master";
      sha256 = "sha256-LzoSC9O6173YcKvMWkSKkxsUVCZYMA844FnDfdr1gVc=";
    };

    nativeBuildInputs = [ prev.unzip ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/themes
      unzip gtk/materia-cyberpunk-neon.zip -d $out/share/themes/

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Cyberpunk Neon GTK theme";
      homepage = "https://github.com/Roboron3042/Cyberpunk-Neon";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };
}
