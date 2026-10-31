# The release wheel includes the built TUI/web assets and agent product tree.
final: prev:
let
  python = prev.python313.override {
    packageOverrides = py: oldPy: {
      # EverOS maintenance needs IndexConfig.index_uuid (absent in 0.32).
      lancedb = py.buildPythonPackage {
        pname = "lancedb";
        version = "0.34.0";
        format = "wheel";
        src = prev.fetchurl {
          url = "https://files.pythonhosted.org/packages/cd/4e/4325c13d5afa93c466428a5a0f168ad4d96f5eb4a77bbe7c5100d39c9897/lancedb-0.34.0-cp39-abi3-manylinux_2_28_x86_64.whl";
          hash = "sha256-BbqKW1jgZO375b5xsavy5BG06vKV0aFz3LGlXFv7UoU=";
        };
        nativeBuildInputs = [ prev.autoPatchelfHook ];
        buildInputs = [ prev.stdenv.cc.cc.lib ];
        dependencies = with py; [ deprecation numpy packaging pyarrow pydantic tqdm lance-namespace ];
        pythonImportsCheck = [ "lancedb" ];
        doCheck = false;
        meta.platforms = [ "x86_64-linux" ];
      };
      # Raven 0.2.6 uses the 1.x protobuf API; nixpkgs has the incompatible 0.3 API.
      a2a-sdk = oldPy.a2a-sdk.overridePythonAttrs (old: {
        version = "1.1.4";
        format = "wheel";
        pyproject = null;
        src = prev.fetchurl {
          url = "https://files.pythonhosted.org/packages/a0/d4/74ab0ea264b36b944f49ec773b40ae108abf6d53a9ec3b3100644e946a06/a2a_sdk-1.1.4-py3-none-any.whl";
          hash = "sha256-uRsDUOGxo++Za3Z2YkRSOJDWsxtarz+dacFF+pfF4M8=";
        };
        doCheck = false;
        dependencies = old.dependencies ++ [ py.json-rpc py.googleapis-common-protos py.packaging ];
        pythonRelaxDeps = [ "protobuf" ];
      });
    };
  };
  # Algorithm packages pinned by EverOS; SVG parsing enables multimodal uploads.
  everalgo-core = python.pkgs.buildPythonPackage {
    pname = "everalgo-core";
    version = "0.3.0";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/2b/5d/ad60747004d873b23443412a74449b39640f08c4f6548fd4442641c3ff17/everalgo_core-0.3.0-py3-none-any.whl";
      hash = "sha256-WiW3hKLSTiinYv7ldRF0powu2haMNTwzdAyjGDBpwCs=";
    };
    dependencies = with python.pkgs; [ openai pydantic tiktoken ];
    pythonImportsCheck = [ "everalgo.config" ];
    doCheck = false;
  };
  everalgo-boundary = python.pkgs.buildPythonPackage {
    pname = "everalgo-boundary";
    version = "0.2.1";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/73/6f/6cb00d36ee007360ac0e2e62c44da782ef881f0f5def9f9d5a64142d88fb/everalgo_boundary-0.2.1-py3-none-any.whl";
      hash = "sha256-layJgikQQbVkGxPJFXkO8gzKjEQBjCAB/2CLE8eua40=";
    };
    dependencies = [ everalgo-core python.pkgs.asgiref ];
    pythonImportsCheck = [ "everalgo.boundary" ];
    doCheck = false;
  };
  everalgo-clustering = python.pkgs.buildPythonPackage {
    pname = "everalgo-clustering";
    version = "0.2.1";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/3c/41/76a14d1aa18a164eef0dd25b8fe43b2aca7a606c33c6af58ec9806a13762/everalgo_clustering-0.2.1-py3-none-any.whl";
      hash = "sha256-QNLkLdZHKjYSawEt9b4IVeoakhUDyGMp/dXZAvKKvAQ=";
    };
    dependencies = [ everalgo-core python.pkgs.numpy ];
    pythonImportsCheck = [ "everalgo.clustering" ];
    doCheck = false;
  };
  everalgo-agent-memory = python.pkgs.buildPythonPackage {
    pname = "everalgo-agent-memory";
    version = "0.4.0";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/5e/7c/98632538a43a1b9a14310e95dd3400c1768b0a15b89072a49ce87e06ba46/everalgo_agent_memory-0.4.0-py3-none-any.whl";
      hash = "sha256-mxHQZqYg34zD5tL6bNCIxE2aoy7vMLxVs8jnku/ua0s=";
    };
    dependencies = [ everalgo-core everalgo-boundary everalgo-clustering python.pkgs.asgiref ];
    pythonImportsCheck = [ "everalgo.agent_memory" ];
    doCheck = false;
  };
  everalgo-parser = python.pkgs.buildPythonPackage {
    pname = "everalgo-parser";
    version = "0.2.1";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/3f/6d/0a79a847e48d4417846916229ad90b0f13e7d348f31c84af30f31a7e0607/everalgo_parser-0.2.1-py3-none-any.whl";
      hash = "sha256-OHbImNg14q5OO9fy9hWF3p/4TBPaVPe71lj3lfjfAH8=";
    };
    dependencies = [ everalgo-core ] ++ (with python.pkgs; [ asgiref beautifulsoup4 httpx pillow cairosvg ]);
    pythonImportsCheck = [ "everalgo.parser" ];
    doCheck = false;
  };
  everalgo-knowledge = python.pkgs.buildPythonPackage {
    pname = "everalgo-knowledge";
    version = "0.1.1";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/0a/8d/3f860b72987f2028facf51733e8e3d85d722808136ea3dd1314bf462b7bd/everalgo_knowledge-0.1.1-py3-none-any.whl";
      hash = "sha256-aqb8cKZedfOA5Jl9xYtp2PXafv/PXE+83r1/5YygGjY=";
    };
    dependencies = [ everalgo-core everalgo-parser ] ++ (with python.pkgs; [ asgiref tiktoken ]);
    pythonImportsCheck = [ "everalgo.knowledge" ];
    doCheck = false;
  };
  everalgo-rank = python.pkgs.buildPythonPackage {
    pname = "everalgo-rank";
    version = "0.4.1";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/bb/1c/5e829ef1176a3e5d030b4a34ff5a0475dcc480d30fdcad7055d48b003e1e/everalgo_rank-0.4.1-py3-none-any.whl";
      hash = "sha256-Z1qBidmuOCTHbSHZvECeDGKj/HMCPQJ0e8/ws5gqLJI=";
    };
    dependencies = [ everalgo-core python.pkgs.asgiref ];
    pythonImportsCheck = [ "everalgo.rank" ];
    doCheck = false;
  };
  everalgo-user-memory = python.pkgs.buildPythonPackage {
    pname = "everalgo-user-memory";
    version = "0.4.0";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/cf/ba/5c7e65281efae449b01b92f37181c39445f763a31b32f798da740413f17a/everalgo_user_memory-0.4.0-py3-none-any.whl";
      hash = "sha256-pAzDuoqoBilCVy7VDjQ0iH+7nnPjHTGIUSRQZTTZ3D4=";
    };
    dependencies = [ everalgo-core everalgo-boundary ] ++ (with python.pkgs; [ asgiref pydantic ]);
    pythonImportsCheck = [ "everalgo.user_memory" ];
    doCheck = false;
  };
  everos = python.pkgs.buildPythonPackage {
    pname = "everos";
    version = "1.4.2";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/bb/11/8b303ea6e97d97929142fa26df5dcc145b725b571208142e7f4012bdd003/everos-1.4.2-py3-none-any.whl";
      hash = "sha256-HFXkOnPhF7rXgQaz+9UB7yMws9CSE1HGQ5ViH+bkoF0=";
    };
    dependencies = [
      everalgo-agent-memory everalgo-boundary everalgo-clustering everalgo-core
      everalgo-knowledge everalgo-rank everalgo-user-memory everalgo-parser
    ] ++ (with python.pkgs; [
      aiosqlite alembic anyio apscheduler click fastapi greenlet jieba
      lancedb openai portalocker prometheus-client pyarrow pydantic-settings
      pydantic python-multipart pyyaml sqlmodel structlog textual typer
      uvicorn watchdog watchfiles
    ]) ++ python.pkgs.uvicorn.optional-dependencies.standard;
    # Arrow schema/maintenance APIs and the Textual CLI pass runtime checks.
    pythonRelaxDeps = [ "pyarrow" "textual" ];
    pythonImportsCheck = [ "everos" "everos.entrypoints.cli.main" ];
    doCheck = false;
  };
  # Keep the adapter paired with the engine version it imports internally.
  everos-memory = python.pkgs.buildPythonPackage {
    pname = "everos-memory";
    version = "1.4.2";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://github.com/EverMind-AI/Raven/releases/download/v0.2.6/everos_memory-1.4.2-py3-none-any.whl";
      hash = "sha256-keQY7cD6Iast0WRzey+CpczRxStHfqJ9iJZs4u+4iVI=";
    };
    # The host loads this plugin; propagating the host back creates a cycle.
    pythonRemoveDeps = [ "raven" ];
    dependencies = [ everos ] ++ (with python.pkgs; [ httpx loguru tomli-w ]);
    # Nix's Python launcher appears as .everos-wrapped in the process table.
    # Recognize it so Raven can safely identify its own server for restart.
    postInstall = ''
      substituteInPlace "$out/${python.sitePackages}/raven_everos/server.py" \
        --replace-fail 'everos(?:\.exe)?' 'everos(?:-wrapped|\.exe)?'
    '';
    pythonImportsCheck = [ "raven_everos" ];
    doCheck = false;
  };
in {
  raven = python.pkgs.buildPythonApplication {
    pname = "raven";
    version = "0.2.6";
    format = "wheel";
    src = prev.fetchurl {
      url = "https://github.com/EverMind-AI/Raven/releases/download/v0.2.6/raven-0.2.6-py3-none-any.whl";
      hash = "sha256-q2/wRbGixAN9+E2m3nVTkv/XEOSczNZE3S8tS8yQMlU=";
    };

    # nixpkgs supplies these as native packages, not PyPI binary wrappers.
    pythonRemoveDeps = [ "ripgrep-bin" "opencv-python-headless" ];
    # Share EverOS's LanceDB 0.34; Raven's vector-store tests cover this pairing.
    # nixpkgs MCP and protobuf also pass the targeted runtime checks.
    pythonRelaxDeps = [ "protobuf" "pydantic-settings" "mcp" "lancedb" ];
    dependencies = with python.pkgs; [
      typer litellm pydantic pydantic-settings httpx loguru
      rich croniter pyyaml prompt-toolkit json-repair tiktoken
      questionary watchfiles tomli-w idna portalocker mcp
      orjson numpy pillow qrcode lancedb aiohttp
      click pyarrow onnxruntime opencv4 shapely pyclipper
      a2a-sdk protobuf lxml truststore pdfplumber pdfminer-six
      pyflakes openai zstandard
    ] ++ [ everos-memory ];
    makeWrapperArgs = [
      "--prefix PATH : ${prev.lib.makeBinPath [ everos prev.nodejs_22 prev.ripgrep prev.git prev.bash prev.coreutils prev.procps ]}"
      "--set LITELLM_LOCAL_MODEL_COST_MAP True"
    ];
    # Downloaded dictionaries/models and the generated trie must be writable.
    # Keep writer and readers on the same per-user resource directory.
    postInstall = ''
      package="$out/${python.sitePackages}/raven"
      substituteInPlace "$package/resources.py" \
        --replace-fail 'PACKAGE = Path(__file__).resolve().parent' \
        'from raven.home import raven_home; PACKAGE = raven_home() / "resources"'
      substituteInPlace "$package/core/tokenizer.py" \
        --replace-fail 'RES_DIR = Path(__file__).resolve().parent / "res"' \
        'from raven.home import raven_home; RES_DIR = raven_home() / "resources" / "core" / "res"'
      # ACP uses a clean login environment. Only children using Raven's own
      # interpreter need its Nix module paths; leave third-party agents alone.
      substituteInPlace "$package/acp_client/client.py" \
        --replace-fail 'argv = resolve_program(argv, child_env, batch_files=True)' \
          'child_env.update({"PYTHONPATH": "'$out'/${python.sitePackages}:${python.pkgs.makePythonPath final.raven.dependencies}", "LITELLM_LOCAL_MODEL_COST_MAP": "True"} if argv[0] == sys.executable else {}); argv = resolve_program(argv, child_env, batch_files=True)'
      substituteInPlace "$package/knowledge/parser/deepdoc/_onnx.py" \
        --replace-fail 'RES_DIR = Path(__file__).resolve().parent.parent.parent / "res"' \
        'from raven.home import raven_home; RES_DIR = raven_home() / "resources" / "knowledge" / "res"'
    '';
    # Raven re-executes sys.executable -m raven for its detached supervisor
    # and gateway. Those children do not run the console script's sys.path setup.
    postFixup = ''
      wrapProgram "$out/bin/raven" \
        --prefix PYTHONPATH : "$out/${python.sitePackages}:${python.pkgs.makePythonPath final.raven.dependencies}"
    '';
    pythonImportsCheck = [ "raven" "raven.cli.entry" "raven.a2a.runtime" "raven.acp_client.client" "raven_everos.backend" ];
    meta = {
      description = "AI agent harness with memory and multi-agent orchestration";
      homepage = "https://github.com/EverMind-AI/Raven";
      license = prev.lib.licenses.asl20;
      mainProgram = "raven";
      platforms = [ "x86_64-linux" ];
    };
  };
}
