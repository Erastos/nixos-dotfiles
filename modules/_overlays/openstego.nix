final: prev: {
  openstego = prev.stdenv.mkDerivation rec {
    pname = "openstego";
    version = "0.8.6";

    src = prev.fetchurl {
      url = "https://github.com/syvaidya/openstego/releases/download/openstego-${version}/openstego-${version}.zip";
      hash = "sha256-QCukGQ0ylWSZahJQuQlvBAJFIEJGn1F1RcMSUnztxB8=";
    };

    nativeBuildInputs = with prev; [ unzip makeWrapper ];

    sourceRoot = "openstego-${version}";

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/openstego $out/bin
      cp -r lib/* $out/share/openstego/

      makeWrapper ${prev.jre}/bin/java $out/bin/openstego \
        --add-flags "-Xmx512m -jar $out/share/openstego/openstego.jar"

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Free steganography solution for data hiding and watermarking";
      homepage = "https://www.openstego.com";
      license = licenses.gpl2Only;
      platforms = platforms.linux;
      sourceProvenance = with sourceTypes; [ binaryBytecode ];
      mainProgram = "openstego";
    };
  };
}
