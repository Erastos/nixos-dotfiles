# lib/mkDevShell.nix
{ system, pkgs, inputs }:

{ name
, packages  ? []
, languages ? {}
, services  ? {}
, scripts   ? {}
, processes ? {}
, shellHook ? ""
}:
inputs.devenv.lib.mkShell {
  # devenv needs inputs to resolve its own internal modules
  inherit inputs pkgs;
  modules = [{
    devenv.root = builtins.toString inputs.self;
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
