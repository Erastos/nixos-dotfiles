{ pkgs, mkDevShell }: mkDevShell {
  name     = "pwn";
  languages.python = { enable = true; version = "3.13"; venv.enable = true; };
  packages = with pkgs; [
    python313Packages.pwntools
    gdb gef patchelf checksec
    binutils file ltrace strace
    radare2 ropper unstable.ghidra-bin xxd
  ];
}
