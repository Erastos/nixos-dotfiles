let
  pkgs = import "<nixpkgs>";
  src = pkgs.fetchFromGitHub {
    # https://github.com/aws/aws-ec2-instance-connect-config
    owner = "aws";
    repo = "aws-ec2-instance-connect-config";
    rev = "1.1.17";
    hash = "sha256-XXrVcmgsYFOj/1cD45ulFry5gY7XOkyhmDV7yXvgNhI=";
  };
in
pkgs.buildFHSEnv {
  name = "eic_run_authorized_keys";
  runScript = "${src}/src/bin/eic_run_authorized_keys";
  targetPkgs = (p: with p; [
    coreutils
    curl
    openssh
    cacert
    gnugrep
    util-linux
    openssl
    gawk
    gnused
  ]);
}
