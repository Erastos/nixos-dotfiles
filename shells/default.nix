{ pkgs, devenv, system }:
let
  mkDevShell = import ../lib/mkDevShell.nix { inherit pkgs devenv system; };
  callShell  = path: import path { inherit pkgs mkDevShell; };
in {
  python   = callShell ./python.nix;
  node     = callShell ./node.nix;
  rust     = callShell ./rust.nix;
  go       = callShell ./go.nix;
  cpp      = callShell ./cpp.nix;
  java     = callShell ./java.nix;
  web      = callShell ./web.nix;
  pwn      = callShell ./pwn.nix;
  security = callShell ./security.nix;
  devops   = callShell ./devops.nix;
  data     = callShell ./data.nix;
}
