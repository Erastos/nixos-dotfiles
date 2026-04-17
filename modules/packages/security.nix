{ ... }:
{
  nixosModuleLib.securityPkgs = { pkgs, ... }:
  {
    programs.adb.enable = true;
    home-manager.users.netscape = {
      home.packages = with pkgs; [
        wireshark
        nmap
        unstable.netexec
        gobuster
        seclists
        netcat-openbsd
        responder
        python313
        unstable.metasploit
        inetutils
        apktool
        jadx
        android-tools
        binwalk
        realm-studio
        dex2jar
        unstable.ghidra-bin
        quark-engine
        exiftool
        foremost
        openstego
        aapt
      ];
    };
  };
}
