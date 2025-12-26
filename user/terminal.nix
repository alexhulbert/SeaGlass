{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix {inherit pkgs;};
in {
  config.home = {
    sessionVariables = {
      FZF_COMPLETE = "2";
      FZF_DISABLE_KEYBINDINGS = "1";
      FZF_LEGACY_KEYBINDINGS = "0";
      FZF_TMUX = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
      GOPATH = "${config.home.homeDirectory}/.go";
      EDITOR = "vim";
      VISUAL = "vim";
    };
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      "/opt/google-cloud-cli/bin"
    ];
  };

  config.home.file.".zshenv" = lib.mkForce {
    text =
      ''
        ${config.lib.shell.exportAll config.home.sessionVariables}
      ''
      + lib.optionalString (config.home.sessionPath != []) ''
        export PATH="$PATH''${PATH:+:}${builtins.concatStringsSep ":" config.home.sessionPath}"
      ''
      + config.home.sessionVariablesExtra;
  };

  config.xdg.configFile."cod/config.toml".source = (pkgs.formats.toml {}).generate "cod.toml" {
    rule = [
      {
        executable = "**";
        policy = "trust";
      }
    ];
  };

  config.xdg.configFile."direnv/direnv.toml".source = (pkgs.formats.toml {}).generate "direnv.toml" {
    global.hide_env_diff = true;
  };

  config.programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
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
        relock = "hyprctl --instance 0 keyword \"misc:allow_session_lock_restore 1\"; hyprctl --instance 0 keyword \"exec hyprlock\"";

        svim = "sudo -e";
        e = "vim";
        se = "svim";
        rm = "safe-rm";

        install = "paru -S";
        ii = "paru -S";
        sw = "home-manager switch && hyprctl reload";

        ldm = "hyprctl dispatch exit";
      };
      initExtra = ''
        bindkey '^A' beginning-of-line
        bindkey '^H' backward-kill-word
        bindkey '5~' kill-word
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word

        ZSH_AUTOSUGGEST_STRATEGY=(history completion)
        ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=magenta'
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

        [[ $- == *i* ]] && eval "$(zoxide init --cmd cd zsh)"
        [[ $- == *i* ]] && alias ls=eza
        [[ $- == *i* ]] && alias cat=bat
      '';
      zplug = {
        enable = true;
        plugins = [
          {name = "zsh-users/zsh-autosuggestions";}
          {name = "chisui/zsh-nix-shell";}
          {name = "zsh-users/zsh-syntax-highlighting";}
          {name = "zsh-users/zsh-history-substring-search";}
          {name = "ptavares/zsh-direnv";}
        ];
      };
    };
    starship = {
      enable = true;
      enableNushellIntegration = false;
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
        directory.read_only = " ";
        custom.env = {
          command = "cat /etc/prompt";
          format = "$output ";
          when = "test -f /etc/prompt";
        };
        rust = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        scala = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        nix_shell = {
          format = "[$symbol$name ]($style)";
          symbol = " ";
        };
        nodejs = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        golang = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        java = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        deno = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        lua = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        docker_context = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        python = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        gcloud.disabled = true;
        aws.disabled = true;
      };
    };
  };
}
