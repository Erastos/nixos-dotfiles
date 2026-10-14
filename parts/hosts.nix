{ ... }: {
  den.hosts.x86_64-linux = {
    Trinity.users.netscape = { };
    Neo.users.netscape     = { };
  };

  # Standalone Home Manager outputs use the same host-qualified user aspects.
  den.homes.x86_64-linux = {
    "netscape@Trinity" = { };
    "netscape@Neo"     = { };
  };
}
