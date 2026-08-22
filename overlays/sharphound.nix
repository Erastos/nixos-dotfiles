# overlays/sharphound.nix
# SharpHound C# BloodHound collector (pre-built .NET 4.7.2 assembly, runs via Mono).
# Supports --collectallproperties (all LDAP properties from all objects) — the
# Python collector (NetExec/bloodhound-ce) does not have this capability.
final: prev:
let
  version = "2.14.0";
  sha256 = "1b1812ae5fca0c9a2a20e2d4e4ffcb6b385b83129248c894c05aab0c24b20715";
in
{
  sharphound = final.stdenv.mkDerivation {
    pname = "sharphound";
    inherit version;

    src = final.fetchurl {
      url = "https://github.com/SpecterOps/SharpHound/releases/download/v${version}/SharpHound_v${version}_windows_x86.zip";
      inherit sha256;
    };

    nativeBuildInputs = [ final.makeWrapper final.unzip ];
    buildInputs = [ final.mono ];

    dontBuild = true;
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/sharphound
      cp -r * $out/lib/sharphound/

      # Pre-seed Mono's UnixRegistryApi with the .NET 4.7.2 release version.
      # SharpHound checks HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\Release >= 461808.
      # Mono's UnixRegistryApi reads MONO_REGISTRY_PATH for the machine store.
      # Key names are lowercased to directory names; values live in values.xml.
      KEYDIR="$out/share/sharphound/registry/LocalMachine/software/microsoft/net framework setup/ndp/v4/full"
      mkdir -p "$KEYDIR"
      cat > "$KEYDIR/values.xml" << 'XML'
      <values>
        <value name="Release" type="int">461808</value>
      </values>
      XML

      # Wrapper: set MONO_REGISTRY_PATH to the pre-seeded registry, then run Mono.
      mkdir -p $out/bin
      makeWrapper ${final.mono}/bin/mono $out/bin/sharphound \
        --set MONO_REGISTRY_PATH "$out/share/sharphound/registry" \
        --add-flags "$out/lib/sharphound/SharpHound.exe"

      runHook postInstall
    '';

    meta = {
      description = "C# Data Collector for BloodHound CE (runs via Mono on Linux)";
      homepage = "https://github.com/SpecterOps/SharpHound";
      license = final.lib.licenses.gpl3Only;
      mainProgram = "sharphound";
      platforms = final.lib.platforms.linux;
    };
  };
}
