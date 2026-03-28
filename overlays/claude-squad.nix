final: prev: {
  claude-squad = prev.buildGoModule rec {
    pname = "claude-squad";
    version = "1.0.17";

    src = prev.fetchFromGitHub {
      owner = "smtg-ai";
      repo = "claude-squad";
      rev = "v${version}";
      hash = "sha256-eZY4CpzHBfkLbkfEpqoZqlk33cB0uVKx9zW3UC8kYiE=";
    };

    vendorHash = "sha256-Rc0pIwnA0k99IKTvYkHV54RxtY87zY1TmmmMl+hYk6Q=";

    nativeBuildInputs = [ prev.makeWrapper ];

    postInstall = ''
      wrapProgram $out/bin/claude-squad \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.tmux prev.gh ]}
    '';

    doCheck = false;
  };
}
