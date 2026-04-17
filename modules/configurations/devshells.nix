{ inputs, ... }:
{
  perSystem = { system, ... }:
  let
    pkgs = import ./../_lib/mkPkgs.nix inputs system;
    mkDevShell = import ./../_lib/mkDevShell.nix {
      self = inputs.self;
      inherit pkgs system;
      devenv = inputs.devenv;
      nixpkgs-python = inputs.nixpkgs-python;
    };
    callShell = path: import path { inherit pkgs mkDevShell; };
  in
  {
    devShells = {
      python   = callShell ./../_shells/python.nix;
      node     = callShell ./../_shells/node.nix;
      rust     = callShell ./../_shells/rust.nix;
      go       = callShell ./../_shells/go.nix;
      cpp      = callShell ./../_shells/cpp.nix;
      java     = callShell ./../_shells/java.nix;
      web      = callShell ./../_shells/web.nix;
      pwn      = callShell ./../_shells/pwn.nix;
      security = callShell ./../_shells/security.nix;
      devops   = callShell ./../_shells/devops.nix;
      data     = callShell ./../_shells/data.nix;
    };
  };
}
