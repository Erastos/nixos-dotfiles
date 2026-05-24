{ ... }: {
  programs.nano.enable         = false;
  environment.variables.EDITOR = "nvim";
}
