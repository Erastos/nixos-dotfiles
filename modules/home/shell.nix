{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.netscape.home.shell;
in
{
  options.netscape.home.shell = {
    enable = lib.mkEnableOption "Zsh shell configuration" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs.man = {
      enable = true;
      generateCaches = true;
    };

    # Ensure SOPS age directory exists
    home.file.".config/sops/age/.keep".text = ''
      # This directory stores age keys for SOPS encryption
      # Place your converted SSH host key here as keys.txt
    '';

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height=40%"
        "--layout=reverse"
        "--border"
        "--inline-info"
        "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
        "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6ac,pointer:#f5e0dc"
        "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6ac,hl+:#f38ba8"
      ];
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetOptions = [ "--preview 'bat --color=always --line-range :200 {}'" ];
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      changeDirWidgetOptions = [ "--preview 'eza --tree --color=always {} | head -100'" ];
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      defaultKeymap = "emacs";
      history.size = 1000;
      history.save = 100000;
      history.share = false;

      zprof.enable = false;

      # Aliases
      shellAliases = {
        # up = "sudo nixos-rebuild switch --flake '${config.home.homeDirectory}/nixos-dotfiles#${osConfig.networking.hostName}' -v";
        up = "nh os switch";
        boot = "sudo nixos-rebuild boot --flake '${config.home.homeDirectory}/nixos-dotfiles#${osConfig.networking.hostName}' -v";
        en = "nvim ${config.home.homeDirectory}/nixos-dotfiles";
        eco = "nvim ${config.xdg.configHome}/nvim";
        nix-shell = "nix-shell --command 'export SHELL=/bin/zsh; zsh'";
        secrets = "cd ${config.home.homeDirectory}/nixos-dotfiles && sops secrets/secrets.yaml";
        k = "kubectl";
        open = "xdg-open";

        # fzf — file & text
        fe      = "fzf --preview 'bat --color=always {}' | xargs -r nvim";
        fman    = "man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r man";
        fenv    = "env | fzf | cut -d= -f1 | xargs -r printenv";
        falias  = "alias | fzf | cut -d= -f1";
        fh      = "eval $(fc -l 1 | fzf +s --tac | sed -E 's/ *[0-9]* *//')";
        fkill   = "ps -f -u $UID | fzf --header-lines=1 | awk '{print $2}' | xargs -r kill -9";
        fssh    = "grep -h 'Host ' ~/.ssh/config ~/.ssh/known_hosts 2>/dev/null | grep -v '[*?]' | awk '{print $2}' | sort -u | fzf | xargs -r ssh";
        fnix    = "nix search nixpkgs 2>/dev/null | fzf";

        # fzf — systemd
        fstart  = "systemctl list-units --type=service --all --no-pager --plain | fzf --header-lines=1 | awk '{print $1}' | xargs -r sudo systemctl start";
        fstop   = "systemctl list-units --type=service --state=running --no-pager --plain | fzf --header-lines=1 | awk '{print $1}' | xargs -r sudo systemctl stop";

        # fzf — docker
        da      = "docker ps -a | sed 1d | fzf -1 | awk '{print $1}' | xargs -r -I{} sh -c 'docker start {} && docker attach {}'";
        ds      = "docker ps | sed 1d | fzf | awk '{print $1}' | xargs -r docker stop";
        drm     = "docker ps -a | sed 1d | fzf -m --tac | awk '{print $1}' | xargs -r docker rm";
        drmi    = "docker images | sed 1d | fzf -m | awk '{print $3}' | xargs -r docker rmi";

        # fzf — kubectl
        kctx    = "kubectl config get-contexts -o name | fzf | xargs -r kubectl config use-context";
        kns     = "kubectl get ns -o name | fzf | cut -d/ -f2 | xargs -r kubectl config set-context --current --namespace";
        klogs   = "kubectl get pods | fzf --header-lines=1 | awk '{print $1}' | xargs -r kubectl logs -f";
      } // lib.optionalAttrs osConfig.netscape.system.htb.enable {
        htb = "sudo systemctl start htb-update.service";
      };

      # Powerlevel 10K Theme
      initContent = ''
        promptinit && prompt powerlevel10k
        source ~/.p10k.zsh

        # Dev shell launcher — hides nix develop --no-pure-eval
        dev() {
          local shell="''${1:?Usage: dev <shell-name>}"
          shift
          nix develop --no-pure-eval "/home/netscape/nixos-dotfiles#''${shell}" "$@"
        }

        # fzf cd — fuzzy jump to any directory
        fcd() {
          local dir
          dir=$(fd --type d --hidden --follow --exclude .git . "''${1:-$HOME}" \
            | fzf --preview 'eza --tree --level=2 {}')
          [[ -n "$dir" ]] && cd "$dir"
        }

        # fzf cd to the directory containing a selected file
        cdf() {
          local file dir
          file=$(fzf +m) && dir=$(dirname "$file") && cd "$dir"
        }

        # fzf ripgrep — live grep with bat preview, opens nvim at matched line
        rgf() {
          local result file line
          result=$(rg --color=always --line-number --no-heading "''${@:-.}" \
            | fzf --ansi --delimiter ':' \
              --preview 'bat --color=always --highlight-line {2} {1}' \
              --preview-window 'up,60%,border-bottom,+{2}+3/3')
          [[ -z "$result" ]] && return
          file=$(echo "$result" | cut -d: -f1)
          line=$(echo "$result" | cut -d: -f2)
          nvim "$file" +"$line"
        }

        # fzf jujutsu bookmark checkout
        fjb() {
          local bookmark
          bookmark=$(jj bookmark list \
            | fzf --preview 'jj log --color=always -r {1}' \
            | awk '{print $1}')
          [[ -n "$bookmark" ]] && jj new "$bookmark"
        }

        # fzf jujutsu log — browse changes, show diff on enter
        fjl() {
          local change
          change=$(jj log --no-graph --color=always \
            -T 'change_id.short() ++ "\t" ++ description.first_line() ++ "\n"' \
            | fzf --ansi --preview 'jj show --color=always {1}' \
            | awk '{print $1}')
          [[ -n "$change" ]] && jj show "$change"
        }

        # fzf jujutsu op log — browse operations, restore on enter
        fjop() {
          local op
          op=$(jj op log --no-graph \
            -T 'id.short() ++ "\t" ++ description.first_line() ++ "\n"' \
            | fzf --ansi --preview 'jj op show {1}' \
            | awk '{print $1}')
          [[ -n "$op" ]] && jj op restore "$op"
        }

        # tmux sessionizer — fzf over project dirs, create or attach to named session
        tms() {
          local selected session_name
          selected=$(find ~/nixos-dotfiles ~/projects 2>/dev/null \
            -mindepth 1 -maxdepth 2 -type d \
            | fzf --preview 'eza --tree --level=2 {}')
          [[ -z "$selected" ]] && return
          session_name=$(basename "$selected" | tr '.' '_')
          if ! tmux has-session -t "$session_name" 2>/dev/null; then
            tmux new-session -ds "$session_name" -c "$selected"
          fi
          if [[ -n "$TMUX" ]]; then
            tmux switch-client -t "$session_name"
          else
            tmux attach-session -t "$session_name"
          fi
        }

        # fzf switch between existing tmux sessions
        fs() {
          local session
          session=$(tmux list-sessions -F "#{session_name}" \
            | fzf --query="$1" --select-1 --exit-0 \
              --preview 'tmux list-windows -t {}')
          [[ -n "$session" ]] && tmux switch-client -t "$session"
        }

        # fzf switch to any pane across all tmux windows
        ftpane() {
          local panes current_pane current_window target target_window target_pane
          panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
          current_pane=$(tmux display-message -p '#I:#P')
          current_window=$(tmux display-message -p '#I')
          target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return
          target_window=$(echo "$target" | awk 'BEGIN{FS=":|-"} {print $1}')
          target_pane=$(echo "$target" | awk 'BEGIN{FS=":|-"} {print $2}' | cut -c1)
          if [[ "$current_window" -eq "$target_window" ]]; then
            tmux select-pane -t "$target_window.$target_pane"
          else
            tmux select-pane -t "$target_window.$target_pane" \
              && tmux select-window -t "$target_window"
          fi
        }

        # fzf systemd — fuzzy control: fsc start / fsc stop / fsc status
        fsc() {
          local unit action="''${1:-status}"
          unit=$(systemctl list-units --type=service --all --no-pager --plain \
            | fzf --header-lines=1 \
              --preview 'systemctl status {1} --no-pager' \
            | awk '{print $1}')
          [[ -n "$unit" ]] && sudo systemctl "$action" "$unit"
        }

        # fzf kubectl exec into a pod shell
        ksh() {
          kubectl get pods | fzf --header-lines=1 \
            --preview 'kubectl describe pod {1}' \
            | awk '{print $1}' \
            | xargs -r -I{} kubectl exec -it {} -- /bin/bash
        }
      '';

      completionInit = "";

      # Antidote plugin manager
      antidote = {
        enable = true;
        plugins = [
          "sindresorhus/pure  kind:fpath"
          "romkatv/powerlevel10k kind:fpath"
        ];
      };
    };
  };
}
