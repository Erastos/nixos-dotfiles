final: prev: {
  beads = prev.buildGoModule rec {
    pname = "beads";
    version = "0.44.0";
    src = prev.fetchFromGitHub {
      owner = "steveyegge";
      repo = "beads";
      rev = "v${version}";
      hash = "sha256-usK4iFG9BvceL1Hdqzmt227O8fvLqAf6VSQe5QpRCKc=";
    };
    nativeBuildInputs = with prev; [ git ];
    vendorHash = "sha256-BpACCjVk0V5oQ5YyZRv9wC/RfHw4iikc2yrejZzD1YU=";
    subPackages = [
      "cmd/bd"
    ];
    doCheck = false;
  };
}
