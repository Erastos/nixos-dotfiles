{ pkgs, mkDevShell }: mkDevShell {
  name     = "python";
  languages.python = { enable = true; version = "3.13"; venv.enable = true; };
  packages = with pkgs; [ ruff pyright ];
}
