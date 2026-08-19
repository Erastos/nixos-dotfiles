final: prev: let
  python = prev.python312.override {
    self = prev.python312;
    packageOverrides = self: super: {
      impacket = super.impacket.overridePythonAttrs {
        version = "0.14.0-unstable-2025-12-03";
        src = prev.fetchFromGitHub {
          owner = "fortra";
          repo = "impacket";
          rev = "caba5facdd3a01b5d0decc6daf5871839f22f792";
          hash = "sha256-W7wXgUq34xzqbi/vEyUoKguaBmKeKGd6u3Oce39JHFc=";
        };
        postPatch = ''
          substituteInPlace setup.py \
            --replace 'version="{}.{}.{}.{}{}"' 'version="{}.{}.{}"'
        '';
      };

      certipy-ad = super.certipy-ad.overridePythonAttrs (oa: {
        pythonRemoveDeps = (oa.pythonRemoveDeps or []) ++ [ "impacket" ];
      });
      bloodhound-ce = self.buildPythonPackage rec {
        pname = "bloodhound-ce";
        version = "1.9.1";
        format = "setuptools";
        src = prev.fetchurl {
          url = "https://files.pythonhosted.org/packages/93/38/74403e5730f3571a0cb42ddecc9b33af491eddb878db92be87b08add2180/bloodhound_ce-1.9.1.tar.gz";
          hash = "sha256-CD3z3DrZmO3P+Ptj/dj1tGSqtf2sjgXMmztlICEPeas=";
        };
        dependencies = with self; [
          dnspython
          impacket
          ldap3
          pyasn1
          pycryptodome
        ];
        postPatch = ''
          ${prev.python3.interpreter} ${./patch-bh-domain.py}
          ${prev.python3.interpreter} ${./patch-bh-auth.py}
        '';
        doCheck = false;
        pythonImportsCheck = [ "bloodhound" ];
      };
    };
  };

  netexecPkg = {
    lib,
    stdenv,
    fetchFromGitHub,
    fetchurl,
    writableTmpDirAsHomeHook,
  }:
  python.pkgs.buildPythonApplication (finalAttrs: {
    pname = "netexec";
    version = "1.5.1";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "Pennyw0rth";
      repo = "NetExec";
      tag = "v${finalAttrs.version}";
      hash = "sha256-BKqBmpA2cSKwC9zX++Z6yTSDIyr4iZVGC/Eea6zoMLQ=";
    };

    pythonRelaxDeps = true;

    pythonRemoveDeps = [
      "neo4j"
    ];

    postPatch = ''
      substituteInPlace nxc/first_run.py \
        --replace-fail "from os import mkdir" "from os import mkdir, chmod" \
        --replace-fail "shutil.copy(default_path, NXC_PATH)" $'shutil.copy(default_path, CONFIG_PATH)\n        chmod(CONFIG_PATH, 0o600)'

      substituteInPlace pyproject.toml \
        --replace-fail " @ git+https://github.com/Pennyw0rth/Certipy" "" \
        --replace-fail " @ git+https://github.com/fortra/impacket" "" \
        --replace-fail " @ git+https://github.com/wbond/oscrypto" "" \
        --replace-fail " @ git+https://github.com/Pennyw0rth/NfsClient" ""
    '';

    build-system = with python.pkgs; [
      poetry-core
      poetry-dynamic-versioning
    ];

    dependencies = with python.pkgs; [
      jwt
      aardwolf
      aioconsole
      aiosqlite
      argcomplete
      asyauth
      beautifulsoup4
      bloodhound-ce
      certipy-ad
      dploot
      dsinternals
      impacket
      lsassy
      masky
      minikerberos
      msgpack
      msldap
      neo4j
      paramiko
      pefile
      pyasn1-modules
      pylnk3
      pynfsclient
      pypsrp
      pypykatz
      python-dateutil
      python-libnmap
      pywerview
      requests
      rich
      sqlalchemy
      termcolor
      terminaltables
      xmltodict
    ];

    nativeCheckInputs = with python.pkgs; [ pytestCheckHook ] ++ [ writableTmpDirAsHomeHook ];

    meta = {
      description = "Network service exploitation tool (maintained fork of CrackMapExec)";
      homepage = "https://github.com/Pennyw0rth/NetExec";
      changelog = "https://github.com/Pennyw0rth/NetExec/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.bsd2;
      maintainers = with lib.maintainers; [ vncsb ];
      mainProgram = "nxc";
      broken = stdenv.hostPlatform.isDarwin;
    };
  });
in {
  netexec = prev.callPackage netexecPkg { };
  bloodhound-ce = python.pkgs.bloodhound-ce;
}