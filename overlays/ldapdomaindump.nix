( self: super: {
    python313 = super.python313.override {
      packageOverrides = pythonSelf: pythonSuper: {
        ldapdomaindump = pythonSuper.ldapdomaindump.overridePythonAttrs (oldAttrs: {
          version = "0.10.0";
          src = super.fetchPypi {
            version = "0.10.0";
            pname = "ldapdomaindump";
            hash = "sha256-y8ZrMqd4dHP/0WnFMZrN5GwC/cnURFVuZEjg3vkdMpk=";
          };
          propagatedBuildInputs = ( builtins.filter (x: x.name != pythonSuper.future.name) oldAttrs.propagatedBuildInputs );
          nativeBuildInputs = [ pythonSuper.pip  ];
          installPhase = ''
            runHook preInstall

            pushd dist >/dev/null

            for wheel in *.whl; do
              echo $wheel;
              ${super.python313}/bin/python -m pip install --prefix "$out" "$wheel"
            done;

            popd >/dev/null

            export PYTHONPATH="$out/lib/python3.13/site-packages:$PYTHONPATH"

            runHook postInstall
          '';
        });
      };
    };
  } 
)
