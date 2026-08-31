final: prev: let
  mkProtonGE = version: hash:
    prev.proton-ge-bin.overrideAttrs (old: {
      inherit version;
      steamDisplayName = version;
      toolName = version;
      src = prev.fetchzip {
        url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
        inherit hash;
      };
    });
in {
  proton-ge-bin-9 = mkProtonGE "GE-Proton9-27"
    "sha256-70au1dx9co3X+X7xkBCDGf1BxEouuw3zN+7eDyT7i5c=";
  proton-ge-bin-8 = mkProtonGE "GE-Proton8-32"
    "sha256-ZBOF1N434pBQ+dJmzfJO9RdxRndxorxbJBZEIifp0w4=";
}
