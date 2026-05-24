{ ... }: {
  imports = [
    ./boot.nix
    ./locale.nix
    ./fonts.nix
    ./nix-settings.nix
    ./editor.nix
    ./packages.nix
    ./man.nix
  ];
}
