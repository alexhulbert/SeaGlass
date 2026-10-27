{ config, pkgs, lib, link, ... }: let
  shim = import ../system-command.nix { inherit pkgs; };
in {
  home = {
    sessionVariables = {
      FZF_COMPLETE = "2";
      FZF_DISABLE_KEYBINDINGS = "1";
      FZF_LEGACY_KEYBINDINGS = "0";
      FZF_TMUX = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
      GOPATH = "${config.home.homeDirectory}/.go";
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "ov";
      JJ_PAGER = "ov";
      SYSTEMD_PAGERSECURE = "0";
    };
    sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
  };

  xdg.configFile."nvim".source = link "modules/home/programs/nvim";

  xdg.configFile."cod/config.toml".source = (pkgs.formats.toml {}).generate "cod.toml" {
    rule = [
      {
        executable = "**";
        policy = "trust";
      }
    ];
  };

  xdg.configFile."direnv/direnv.toml".source = (pkgs.formats.toml {}).generate "direnv.toml" {
    global.hide_env_diff = true;
  };

  xdg.configFile."ov/config.yaml".source = (pkgs.formats.yaml {}).generate "ov.yaml" {
    ClipboardMethod = "OSC52";
    IsWriteOriginal = true;
    QuitSmall = true;
  };

  xdg.configFile."pacman/makepkg.conf".text = ''
    SRCDEST="${config.xdg.cacheHome}/makepkg/sources"
    BUILDDIR="${config.xdg.cacheHome}/makepkg/build"
    PKGDEST="${config.xdg.cacheHome}/makepkg/packages"
    SRCPKGDEST="${config.xdg.cacheHome}/makepkg/sources"
  '';

  programs = {
    bat = {
      enable = true;
      package = shim "bat";
      config = {
        pager = "ov -n";
        paging = "always";
        style = "plain";
        wrap = "never";
      };
    };
    direnv = {
      enable = true;
      package = shim "direnv";
    };
    zsh = {
      enable = true;
      package = shim "zsh";
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        start = "sudo systemctl start";
        stop = "sudo systemctl stop";
        enable = "sudo systemctl enable";
        disable = "sudo systemctl disable";
        restart = "sudo systemctl restart";
        systatus = "sudo systemctl status";
        log = "sudo journalctl -xeu";

        ustart = "systemctl start --user";
        ustop = "systemctl stop --user";
        uenable = "systemctl enable --user";
        udisable = "systemctl disable --user";
        urestart = "systemctl restart --user";
        usystatus = "systemctl status --user";
        ulog = "journalctl --user -xeu";

        svim = "sudo -e";
        e = "nvim";
        vim = "nvim";
        vi = "nvim";
        vimdiff = "nvim -d";
        se = "svim";
        rm = "safe-rm";
        ls = "eza";
        cat = "bat";

        install = "paru -S";
        ii = "paru -S";
      };
      initContent = ''
        ZSH_AI_CMD_PROVIDER=claude-code
        export LS_COLORS='di=34:ln=36:ex=32:or=31'

        bindkey '^A' beginning-of-line
        bindkey '^H' vi-backward-kill-word
        bindkey '5~' kill-word
        bindkey '^[[1;5C' vi-forward-word
        bindkey '^[[1;5D' vi-backward-word
        bindkey '^?' backward-delete-char
        bindkey '^[[3~' delete-char

        ZSH_AUTOSUGGEST_STRATEGY=(history completion)
        WORDCHARS="*?_-.[]~=&;!#$%^(){}<>"

        . /usr/share/fzf/completion.zsh
        . /usr/share/fzf/key-bindings.zsh

        . /usr/share/doc/pkgfile/command-not-found.zsh

        source <(cod init $$ zsh)

        zstyle ':completion:*' menu select
        zstyle ':completion::complete:*' gain-privileges 1

        autoload -U up-line-or-beginning-search
        autoload -U down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "^[[A" up-line-or-beginning-search
        bindkey "^[[B" down-line-or-beginning-search

        eval "$(zoxide init --cmd cd zsh)"

        gsu() {
          run0 --background= /usr/bin/env \
            "WAYLAND_DISPLAY=$WAYLAND_DISPLAY" "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR" "$@"
        }
      '';
      plugins = [
        {
          name = "zsh-nix-shell";
          src = pkgs.zsh-nix-shell;
          file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        }
        {
          name = "zsh-ai-cmd";
          src = pkgs.fetchFromGitHub {
            owner = "kylesnowschwartz";
            repo = "zsh-ai-cmd";
            rev = "e40b23f00dc6e678a52a481e3a82d9fbaf8913c8";
            hash = "sha256-TTkRZ9N9dL/IdyEIGCgnTE6L0DcoJiNQcY7+YVurdMU=";
          };
        }
      ];
    };
    starship = {
      enable = true;
      settings = {
        character = {
          success_symbol = "[](bold)";
          error_symbol = "[](bold)";
        };
        format = "$custom$character";
        right_format = "$all";
        add_newline = false;
        line_break.disabled = true;
        package.disabled = true;
        container.disabled = true;
        git_status = {
          untracked = "";
          stashed = "";
          modified = "";
          staged = "";
          renamed = "";
          deleted = "";
        };
        terraform.symbol = " ";
        git_branch.symbol = " ";
        directory.read_only = " 󰌾";
        custom.env = {
          command = "cat /etc/prompt";
          format = "$output ";
          when = "test -f /etc/prompt";
        };
        nix_shell = {
          format = "[$symbol$name ]($style)";
          symbol = " ";
        };
        gcloud.disabled = true;
        aws.disabled = true;
      } // lib.mapAttrs (_: symbol: { format = "[$symbol]($style)"; inherit symbol; }) {
        rust = " ";
        scala = " ";
        nodejs = " ";
        golang = " ";
        java = " ";
        deno = " ";
        lua = " ";
        docker_context = " ";
        python = " ";
      };
    };
  };
}
