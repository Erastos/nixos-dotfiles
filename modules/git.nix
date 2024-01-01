{ config, lib, pkgs, home-manager, ...}:

{
  programs.git = {
    enable = true;
    extraConfig = {user = {name = "Andrew Smith"; email = "andrew@andrewnsmith.net";}; };
  };

  programs.gh.enable = true;
}

