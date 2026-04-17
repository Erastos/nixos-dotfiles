{ pkgs, mkDevShell }: mkDevShell {
  name     = "rust";
  languages.rust.enable = true;
  packages = with pkgs; [ pkg-config ];
}
