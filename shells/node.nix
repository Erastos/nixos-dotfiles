{ pkgs, mkDevShell }: mkDevShell {
  name     = "node";
  languages.javascript = { enable = true; npm.enable = true; };
  packages = with pkgs; [ nodePackages.yarn pnpm typescript ];
}
