{ den, ... }: {
  den.aspects.shared-nixos = {
    includes = [
      den.aspects.core
      den.aspects.secrets
      den.aspects.audio
      den.aspects.users
      den.aspects.networking
      den.aspects.hardware
      den.aspects.desktop
      den.aspects.services
      den.aspects.virtualisation
      den.aspects.security-tools
      den.aspects.bloodhound-ce
      den.aspects.openclaw
    ];
  };

  den.aspects.shared-hm = {
    homeManager.imports = [ ../../../modules/home ];
  };
}
