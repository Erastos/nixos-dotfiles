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
    ];

    nixos = { ... }: {
      netscape.system.networking.firewall.http.enable = true;
      netscape.system.htb.enable = true;
      netscape.system.htb.vpn.enable = true;
      netscape.system.services.docker.enable = true;
    };
  };

  den.aspects.shared-hm = {
    homeManager.imports = [ ../../../modules/home ];
  };
}
