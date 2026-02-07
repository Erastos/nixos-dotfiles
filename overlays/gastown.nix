final: prev: {
  gastown = prev.buildGoModule rec {
    pname = "gastown";
    version = "0.5.0";

    src = prev.fetchFromGitHub {
      owner = "steveyegge";
      repo = "gastown";
      rev = "v${version}";
      hash = "sha256-mtouqawxbaLruvBNuXSyYCwREEg1mi0SFQRLfOdJQxI=";
    };

    vendorHash = "sha256-ripY9vrYgVW8bngAyMLh0LkU/Xx1UUaLgmAA7/EmWQU=";
    subPackages = [
      "cmd/gt"
    ];
  };
}
