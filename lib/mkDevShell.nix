# lib/mkDevShell.nix
{ pkgs, devenv, system }:

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
  inputs = { inherit devenv; nixpkgs = { legacyPackages.${system} = pkgs; }; };
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
