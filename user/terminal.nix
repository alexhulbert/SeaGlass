{
  config,
  pkgs,
  lib,
  ...
}:
let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
  sgptInit = builtins.readFile (
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/TheR1D/shell_gpt/shell-integrations/simple_zsh.sh";
      sha256 = "sha256:0794ly0dsv5c1fpbr63gk0b2pvbhvn3k9ka4h8qnbz05mdqws525";
    }
  );
in {
  config.home = {
    sessionVariables = {
      FZF_COMPLETE = "2";
      FZF_DISABLE_KEYBINDINGS = "1";
      FZF_LEGACY_KEYBINDINGS = "0";
      FZF_TMUX = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
      GOPATH = "${config.home.homeDirectory}/.go";
    };
  };

  config.home.file.".zshenv" = lib.mkForce { text =
    ''
      ${config.lib.shell.exportAll config.home.sessionVariables}
    ''
    + lib.optionalString (config.home.sessionPath != []) ''
      export PATH="$PATH''${PATH:+:}${pkgs.builtins.concatStringsSep ":" config.home.sessionPath}"
    ''
    + config.home.sessionVariablesExtra; };

  config.programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      shellAliases = {
        start = "sudo systemctl start";
        stop = "sudo systemctl stop";
        restart = "sudo systemctl restart";
        systatus = "sudo systemctl status";
        log = "sudo journalctl";

        ustart = "systemctl start --user";
        ustop = "systemctl stop --user";
        urestart = "systemctl restart --user";
        usystatus = "systemctl status --user";
        ulog = "journalctl --user";

        rstart = "rdx systemctl start";
        rstop = "rdx systemctl stop";
        rrestart = "rdx systemctl restart";
        rsystatus = "rdx systemctl status";
        rlog = "rdx journalctl";

        e = "vim";
        se = "svim";
        ls = "eza";
        cat = "bat";

        sw = "home-manager switch";

        ldm = "qdbus org.kde.ksmserver /KSMServer logout 0 3 3";
      };
      initExtra = ''
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

        PATH=$PATH:~/.local/bin
        ${builtins.replaceStrings ["^l"] ["^g"] sgptInit}
      '';
      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "chisui/zsh-nix-shell"; }
          { name = "zsh-users/zsh-syntax-highlighting"; }
          { name = "zsh-users/zsh-history-substring-search"; }
        ];
      };
    };
    starship = {
      enable = true;
      package = shim {
        name = "starship";
        cmds = ["starship"];
      };
      enableNushellIntegration = false;
      settings = {
        character = {
          success_symbol = "[‍](bold)";
          error_symbol = "[‍](bold)";
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
