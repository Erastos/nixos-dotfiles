# lib/mkDevShell.nix
{ self, pkgs, devenv, system, nixpkgs-python }:

{ name
, packages  ? []
, languages ? {}
, services  ? {}
, scripts   ? {}
, processes ? {}
, shellHook ? ""
}:

devenv.lib.mkShell {
  # devenv needs inputs to resolve its own internal modules
  inputs = { inherit self devenv nixpkgs-python; nixpkgs = { legacyPackages.${system} = pkgs; }; };
  inherit pkgs;
  modules = [{
    inherit packages languages services scripts processes;

    enterShell = ''
      if [ -z "$NETSCAPE_DEVSHELL" ]; then
        export NETSCAPE_DEVSHELL="${name}"
        export SHELL="${pkgs.zsh}/bin/zsh"
        exec ${pkgs.zsh}/bin/zsh
      fi
    '' + shellHook;
  }];
}
