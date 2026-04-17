{ ... }:
{
  nixosModuleLib.core = { pkgs, ... }:
  {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    time.timeZone = "America/New_York";
    environment.systemPackages = with pkgs; [ ntp wget ];

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };

    fonts.packages = [
      pkgs.nerd-fonts.hack
      pkgs.nerd-fonts.blex-mono
    ];

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
      cores = 0;
      auto-optimise-store = true;
    };
    nix.package = pkgs.lix;

    programs.nano.enable = false;
    environment.variables.EDITOR = "nvim";
  };
}
