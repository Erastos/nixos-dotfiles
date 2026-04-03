{ ... }:

{
  imports = [
    ./core.nix
    ./hardware.nix
    ./networking.nix
    ./audio.nix
    ./desktop.nix
    ./services.nix
    ./users.nix
    ./htb.nix
    ./openclaw.nix
    ./secrets.nix
    ./virtualization.nix
  ];
}
