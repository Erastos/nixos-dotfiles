final: prev: {
  llm-agents = prev.llm-agents // {
    prime-agent = prev.llm-agents.prime-agent.override {
      # llm-agents.nix's MCP 2 package references httpx2, which nixpkgs
      # does not yet provide. These are separate packages from httpx/httpcore.
      python3 = final.python3.override {
        packageOverrides = pyFinal: _: let
          idna = pyFinal.buildPythonPackage {
            pname = "idna";
            version = "3.18";
            format = "wheel";
            src = final.fetchurl {
              url = "https://files.pythonhosted.org/packages/1e/5e/d4e9f1a599fb8e573b7b87160658329fbf28d19eac2718f51fc3def3aa5a/idna-3.18-py3-none-any.whl";
              sha256 = "7f952cbe720b688055e3f87de14f5c3e5fdaa8bc3928985c4077ca689de849a2";
            };
            pythonImportsCheck = [ "idna" ];
          };
          httpcore2 = pyFinal.buildPythonPackage {
            pname = "httpcore2";
            version = "2.13.0";
            format = "wheel";
            src = final.fetchurl {
              url = "https://files.pythonhosted.org/packages/7e/0d/117a771a2bb91df334b66bf4da14cd02f21aefbcfe53180f336ce55e8f90/httpcore2-2.13.0-py3-none-any.whl";
              sha256 = "35ae5be347aa40467b4a5dc032ac67ebb6d27189fc97e8cebcf99616f6a1bb9e";
            };
            dependencies = with pyFinal; [ h11 truststore ];
            pythonImportsCheck = [ "httpcore2" ];
          };
        in {
          inherit httpcore2 idna;
          httpx2 = pyFinal.buildPythonPackage {
            pname = "httpx2";
            version = "2.13.0";
            format = "wheel";
            src = final.fetchurl {
              url = "https://files.pythonhosted.org/packages/fe/d1/a0c72b0e006df654709fbc366cc5bcb53e5aee13e1e3395152c6dd293376/httpx2-2.13.0-py3-none-any.whl";
              sha256 = "fc12720cedf72faa26cca6b4ca394e05c894e7d7933fc45cafe767960804e49a";
            };
            dependencies = with pyFinal; [ anyio httpcore2 idna truststore ];
            pythonImportsCheck = [ "httpx2" ];
          };
        };
      };
    };
  };
}
