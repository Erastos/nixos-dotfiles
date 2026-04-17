{ pkgs, mkDevShell }: mkDevShell {
  name     = "data";
  languages.python = { enable = true; version = "3.13"; venv.enable = true; };
  packages = with pkgs; [
    python313Packages.numpy python313Packages.pandas
    python313Packages.matplotlib python313Packages.scikit-learn
    python313Packages.jupyter
  ];
}
