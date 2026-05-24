{ inputs, ...}: {
  perSystem = { system, ... }: {
    devShells = import ../shells { inherit system inputs; };
  };
}
