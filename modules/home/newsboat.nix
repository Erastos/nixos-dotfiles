{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.newsboat;
in
{
  options.netscape.home.newsboat = {
    enable = lib.mkEnableOption "Enable Newsboat Config" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs.newsboat = {
      enable = true;
      autoReload = true;
      urls = [
        ({
          url = "https://akselmo.dev/feed.xml";
          title = "AksDev";
          tags = ["Tech" "Programming"];
        })
        ({
          url = "https://www.bitsaboutmoney.com/archive/rss/";
          title = "Bits about Money";
          tags = ["Finance"];
        })
        ({
          url = "https://conway.scot/atom.xml";
          title = "Scott Conway Blog";
          tags = ["Tech" "Security"];
        })
        ({
          url = "https://www.hiro.report/rss/";
          title = "The Hiro Report";
          tags = ["Tech"];
        })
      ];
    };

  };

}
