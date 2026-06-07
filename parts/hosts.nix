{ den, ... }: {
  den.hosts.x86_64-linux = {
    Trinity.users.netscape.aspect = den.aspects.netscape-trinity;
    Neo.users.netscape.aspect     = den.aspects.netscape-neo;
  };

  den.homes.x86_64-linux = {
    "netscape@Trinity".aspect = den.aspects.netscape-trinity;
    "netscape@Neo".aspect     = den.aspects.netscape-neo;
  };
}
