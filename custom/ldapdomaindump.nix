let
  pkgs = import <nixpkgs> { };
in 
with pkgs.python313Packages;
buildPythonPackage rec {
  pname = "ldapdomaindump";
  version = "0.10.0";
  format = "setuptools";

  dontUsePypaInstall = true;

  installPhase = ''
    runHook preInstall

    pushd dist >/dev/null

    for wheel in *.whl; do
      echo $wheel;
      ${pkgs.python313}/bin/python -m pip install --prefix "$out" "$wheel"
    done;

    popd >/dev/null

    export PYTHONPATH="$out/lib/python3.13/site-packages:$PYTHONPATH"

    runHook postInstall
  '';

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-y8ZrMqd4dHP/0WnFMZrN5GwC/cnURFVuZEjg3vkdMpk=";
  };

  propagatedBuildInputs = [
    dnspython
    ldap3
  ];

  # requires ldap server
  doCheck = false;

  pythonImportsCheck = [ "ldapdomaindump" ];
  
  nativeBuildInputs = [ pip pkgs.breakpointHook ];

  meta = with pkgs.lib; {
    description = "Active Directory information dumper via LDAP";
    homepage = "https://github.com/dirkjanm/ldapdomaindump/";
    changelog = "https://github.com/dirkjanm/ldapdomaindump/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
  };
}
