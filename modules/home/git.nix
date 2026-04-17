{ ... }:
{
  homeModuleLib.git = {
    programs.git = {
      enable = true;
      settings.user = {
        name = "Andrew Smith";
        email = "andrew@andrewnsmith.net";
      };
    };
    programs.gh.enable = true;
  };
}
