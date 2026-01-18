{ config, lib, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = false;
    };
    theme = "1984 Dark";
  };
  
}
