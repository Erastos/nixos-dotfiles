{ inputs, system }:
let
  enterShell = ''
  if [ -z "$NETSCAPE_DEVSHELL" ]; then
      export NETSCAPE_DEVSHELL="devshell"
      export SHELL="${pkgs.zsh}/bin/zsh"
      exec ${pkgs.zsh}/bin/zsh
  fi
  '';
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  unstableOverlays = builtins.map (name: import (../overlays/unstable + "/${name}"))
    (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
      (builtins.attrNames (builtins.readDir ../overlays/unstable)));
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
    config.permittedInsecurePackages = [ "openclaw-2026.4.12" ];
    overlays = unstableOverlays;
  };
  rootModule = { devenv.root = builtins.toString inputs.self; };
in
{
  python = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        languages.python = {
          enable = true;
          version = "3.13";
          venv.enable = true;
        };
      })
    ];
  };
  web = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        packages = with pkgs; [
          burpsuite sqlmap ffuf gobuster
          unstable.feroxbuster
          curl wget httpie nikto proxychains-ng wfuzz
        ];
      })
    ];
  };
  security = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        packages = with pkgs; [
          nmap unstable.netexec unstable.bloodhound-ce gobuster unstable.seclists
          netcat-openbsd responder hashcat
          unstable.metasploit wireshark tcpdump
          python3Packages.impacket bloodhound binwalk xxd curl
        ];
      })
    ];
  };
  rust = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        languages.rust.enable = true;
        packages = with pkgs; [
          pkg-config
        ];
      })
    ];
  };
  pwn = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        languages.python = {
          enable = true;
          version = "3.13";
          venv.enable = true;
        };
        packages = with pkgs; [
          python313Packages.pwntools
          gdb gef patchelf checksec
          binutils file ltrace strace
          radare2 python313Packages.ropper
          unstable.ghidra-bin xxd
        ];
      })
    ];
  };
  node = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        languages.javascript = {
          enable = true;
          npm.enable = true;
        };
        packages = with pkgs; [
          yarn pnpm typescript
        ];
      })
    ];
  };
  java = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        languages.java = {
          enable = true;
          jdk.package = pkgs.jdk21;
        };
        packages = with pkgs; [
          maven gradle
        ];
      })
    ];
  };
  go = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        languages.go = {
          enable = true;
        };
        packages = with pkgs; [
          delve
        ];
      })
    ];
  };
  devops = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        packages = with pkgs; [
          docker-compose kubectl k9s helm
          unstable.terraform ansible
          sops age skopeo jq yq-go
        ];
      })
    ];
  };
  data = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        languages.python = {
          enable = true;
          version = "3.13";
          venv.enable = true;
        };
        packages = with pkgs; [
          python313Packages.numpy python313Packages.pandas
          python313Packages.matplotlib python313Packages.scikit-learn
          python313Packages.jupyter
        ];
      })
    ];
  };
  cpp = inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      rootModule
      ({ pkgs, config, ...}: {
        inherit enterShell;
        packages = with pkgs; [
          gcc clang cmake gnumake gdb valgrind boost catch2 pkg-config
        ];
      })
    ];
  };
}
