{ pkgs, mkDevShell }: mkDevShell {
  name     = "go";
  languages.go.enable = true;
  packages = with pkgs; [ delve ];
}
