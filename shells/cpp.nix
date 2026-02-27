{ pkgs, mkDevShell }: mkDevShell {
  name     = "cpp";
  packages = with pkgs; [ gcc clang cmake gnumake gdb valgrind boost catch2 pkg-config ];
}
