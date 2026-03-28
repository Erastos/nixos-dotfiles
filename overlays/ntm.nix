final: prev: {
  ntm = prev.buildGoModule rec {
    pname = "ntm";
    version = "1.10.0";

    src = prev.fetchFromGitHub {
      owner = "Dicklesworthstone";
      repo = "ntm";
      rev = "v${version}";
      hash = "sha256-42Eb0EZVILMPSeSd0Q6KpbHF+BLuzwmdEGeSLXVlGbg=";
    };

    vendorHash = "sha256-DTWHrvXcmfcMTVtwTcoWvZFuzJGJg2aAlVBtJ/uyiBo=";

    subPackages = [ "cmd/ntm" ];

    ldflags = [
      "-s"
      "-w"
      "-X github.com/Dicklesworthstone/ntm/internal/cli.Version=${version}"
    ];

    nativeBuildInputs = [ prev.makeWrapper ];

    postInstall = ''
      wrapProgram $out/bin/ntm \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.tmux prev.gh ]}
    '';

    doCheck = false;
  };
}
