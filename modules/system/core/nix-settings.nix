{ pkgs, ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs              = "auto";
    cores                 = 0;
    auto-optimise-store   = true;
    extra-substituters        = [ "https://attic.xuyh0120.win/lantian" ];
    extra-trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };
  nix.package = pkgs.unstable.lix;
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/netscape/nixos-dotfiles/";
  };
}
