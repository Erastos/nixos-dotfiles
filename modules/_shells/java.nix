{ pkgs, mkDevShell }: mkDevShell {
  name     = "java";
  languages.java = { enable = true; jdk.package = pkgs.jdk21; };
  packages = with pkgs; [ maven gradle ];
}
