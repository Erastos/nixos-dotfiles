{ ... }: {
  imports = [
    ./colors.nix
    ./shell.nix
    ./terminals.nix
    ./editors.nix
    ./wm
    ./git.nix
    ./gtk.nix
    ./newsboat.nix
    ./coding-agents.nix
    ./openclaw.nix
    ./packages/general.nix
    ./packages/hardware.nix
    ./packages/development.nix
    ./packages/devops.nix
    ./packages/security.nix
    ./packages/ai-tools.nix
    ./sioyek.nix
  ];
}
