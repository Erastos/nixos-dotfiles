final: prev: {
  ansible-language-server = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "ansible-language-server";
    version = "1.2.4";

    src = prev.fetchFromGitHub {
      owner = "ansible";
      repo = "vscode-ansible";
      rev = "v26.1.3";
      hash = "sha256-DsEW3xP8Fa9nwPuyEFVqG6rvAZgr4TDB6jhyixdvqt8=";
    };

    missingHashes = ./ansible-language-server-missing-hashes.json;

    offlineCache = prev.yarn-berry_4.fetchYarnBerryDeps {
      inherit (finalAttrs) src missingHashes;
      hash = "sha256-GScYVFdG8MMtPjtXfz7e6Y+A1tFMF9T8suvU+/BhsHY=";
    };

    nativeBuildInputs = with prev; [
      nodejs
      yarn-berry_4
      yarn-berry_4.yarnBerryConfigHook
      makeWrapper
    ];

    # Skip native module builds (keytar etc.) — not needed for the language server
    YARN_ENABLE_SCRIPTS = "0";

    buildPhase = ''
      runHook preBuild
      cd packages/ansible-language-server
      yarn compile
      cd ../..
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/ansible-language-server
      cp -r packages/ansible-language-server/out $out/lib/ansible-language-server/
      cp -r packages/ansible-language-server/bin $out/lib/ansible-language-server/
      cp packages/ansible-language-server/package.json $out/lib/ansible-language-server/

      # Copy hoisted root node_modules first, then overlay workspace-specific ones
      cp -r node_modules $out/lib/ansible-language-server/

      # Remove workspace symlinks that point to non-existent monorepo packages
      find $out/lib/ansible-language-server/node_modules -type l ! -exec test -e {} \; -delete

      if [ -d packages/ansible-language-server/node_modules ]; then
        cp -r --no-clobber packages/ansible-language-server/node_modules/* $out/lib/ansible-language-server/node_modules/ 2>/dev/null || true
      fi

      # Create bin wrapper
      mkdir -p $out/bin
      makeWrapper ${prev.nodejs}/bin/node \
        $out/bin/ansible-language-server \
        --add-flags "$out/lib/ansible-language-server/bin/ansible-language-server"
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Ansible Language Server";
      homepage = "https://github.com/ansible/vscode-ansible";
      license = licenses.mit;
      mainProgram = "ansible-language-server";
    };
  });
}
