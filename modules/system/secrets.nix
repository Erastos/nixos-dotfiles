{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.secrets;
in
{
  options.netscape.system.secrets = {
    enable = lib.mkEnableOption "sops-nix secrets management" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      # Use SSH host key for decryption
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      # Default secrets file
      defaultSopsFile = ../../secrets/secrets.yaml;

      # Validate sops files at build time
      validateSopsFiles = true;
    };
  };
}
