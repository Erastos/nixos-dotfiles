{ pkgs, ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs              = "auto";
    cores                 = 0;
    auto-optimise-store   = true;
  };
  nix.package = pkgs.lix;
}
