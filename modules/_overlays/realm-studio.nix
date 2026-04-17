final: prev:

let
  inherit (prev) lib stdenv stdenvNoCC;

  # Platform-specific versions
  macOSVersion = "15.2.1";
  linuxVersion = "20.0.0";

  # Platform-specific sources
  darwinSrc = prev.fetchurl {
    url = "https://static.realm.io/downloads/realm-studio/Realm%20Studio-${macOSVersion}-mac.zip";
    hash = "sha256-Vvc432P7VQxCVcS7i7JwOx7ByhX+Ea0Oz7ogvAH8Xoo=";
  };

  linuxSrc = prev.fetchurl {
    url = "https://github.com/realm/realm-studio/releases/download/v${linuxVersion}/Realm.Studio-${linuxVersion}.AppImage";
    hash = "sha256-dAQ0ZbY8X18vRgm52HbjeQ1QKCASByAJkcCnFSy/uxQ=";
  };

in
{
  realm-studio = stdenv.mkDerivation (finalAttrs: {
    pname = "realm-studio";
    version = if stdenv.isDarwin then macOSVersion else linuxVersion;

    src = if stdenv.isDarwin then darwinSrc else linuxSrc;

    sourceRoot = if stdenv.isDarwin then "." else null;

    nativeBuildInputs = if stdenv.isDarwin then [
      prev.unzip
    ] else [
      prev.appimage-run
      prev.makeWrapper
      prev.autoPatchelfHook
    ];

    buildInputs = lib.optionals (!stdenv.isDarwin) [
      prev.electron
      prev.gtk3
      prev.libdrm
      prev.mesa
      prev.alsa-lib
    ];

    unpackPhase = if stdenv.isDarwin then ''
      runHook preUnpack
      unzip $src
      runHook postUnpack
    '' else ''
      runHook preUnpack

      # Extract AppImage using appimage-run
      ${prev.appimage-run}/bin/appimage-run -x squashfs-root $src

      runHook postUnpack
    '';

    dontBuild = true;
    dontConfigure = true;

    installPhase = if stdenv.isDarwin then ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r "Realm Studio.app" $out/Applications/
      runHook postInstall
    '' else ''
      runHook preInstall

      # Create directories
      mkdir -p $out/bin
      mkdir -p $out/lib/realm-studio
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons/hicolor/512x512/apps

      # Install the application
      cp -r squashfs-root/resources/app.asar $out/lib/realm-studio/

      # Copy resources if they exist
      if [ -d squashfs-root/resources ]; then
        cp -r squashfs-root/resources $out/lib/realm-studio/ || true
      fi

      # Install desktop entry
      if [ -f squashfs-root/realm-studio.desktop ]; then
        cp squashfs-root/realm-studio.desktop $out/share/applications/
      elif [ -f squashfs-root/Realm\ Studio.desktop ]; then
        cp squashfs-root/Realm\ Studio.desktop $out/share/applications/realm-studio.desktop
      else
        # Create a basic desktop entry if none exists
        cat > $out/share/applications/realm-studio.desktop << EOF
[Desktop Entry]
Name=Realm Studio
Exec=realm-studio
Type=Application
Icon=realm-studio
Categories=Development;Database;
Comment=Visual tool to view, edit, and model Realm databases
Terminal=false
EOF
      fi

      # Install icon
      if [ -f squashfs-root/realm-studio.png ]; then
        cp squashfs-root/realm-studio.png $out/share/icons/hicolor/512x512/apps/
      elif [ -f squashfs-root/usr/share/icons/hicolor/512x512/apps/realm-studio.png ]; then
        cp squashfs-root/usr/share/icons/hicolor/512x512/apps/realm-studio.png $out/share/icons/hicolor/512x512/apps/
      fi

      # Create wrapper script
      makeWrapper ${prev.electron}/bin/electron $out/bin/realm-studio \
        --add-flags "$out/lib/realm-studio/app.asar" \
        --set-default ELECTRON_IS_DEV 0

      runHook postInstall
    '';

    meta = with lib; {
      description = "Visual tool to view, edit, and model Realm databases";
      homepage = "https://www.mongodb.com/docs/atlas/device-sdks/studio/";
      license = licenses.asl20;
      maintainers = with maintainers; [ matteopacini ];
      platforms = platforms.unix;
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      mainProgram = "realm-studio";
    };
  });
}
