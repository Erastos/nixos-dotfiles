{ lib, ... }:

{
  burgundy-red = import ./burgundy-red.nix { inherit lib; };
  blue-matrix = import ./blue-matrix.nix { inherit lib; };
  cyberpunk-neon = import ./cyberpunk-neon.nix { inherit lib; };
  enterprise-2000 = import ./enterprise-2000.nix { inherit lib; };
}
