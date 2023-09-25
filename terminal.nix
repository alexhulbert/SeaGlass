{
  config,
  pkgs,
  lib,
  ...
}: {
  config.home = {
    sessionVariables = {
      FZF_COMPLETE = "2";
      FZF_DISABLE_KEYBINDINGS = "1";
      FZF_LEGACY_KEYBINDINGS = "0";
      FZF_TMUX = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
      GOPATH = "/home/alex/.go";
    };

    packages = [
      (
        pkgs.writeTextFile {
          name = "hm-session-vars.sh";
          destination = "/etc/profile.d/hm-session-vars-2.sh";
          text =
            ''
              ${config.lib.shell.exportAll config.home.sessionVariables}
            ''
            + lib.optionalString (config.home.sessionPath != []) ''
              export PATH="$PATH''${PATH:+:}${pkgs.builtins.concatStringsSep ":" config.home.sessionPath}"
            ''
            + config.home.sessionVariablesExtra;
        }
      )
    ];
  };

  config.xdg.configFile = {
    "fish/conf.d/hm-session-vars.fish".text = ''
      set --prepend fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars-2.sh > /dev/null
      set -e fish_function_path[1]
    '';
    "fish/conf.d/theme.fish".text = ''
      # fenv source ${config.home.homeDirectory}/.cache/wal/colors-tty.sh
      cat ${config.home.homeDirectory}/.cache/wal/sequences &
      source ${config.home.homeDirectory}/.cache/wal/pywal.fish
    '';
    "wal/templates/pywal.fish".source = ./resources/theme/pywal.fish;
    # "fish/conf.d/any-nix-shell.fish".text = ''
    #   any-nix-shell fish --info-right | source
    # '';
    "fish/conf.d/work.fish".text = ''
      test -d /run/host && begin
        export GDK_PIXBUF_MODULE_FILE=/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
        export QT_PLUGIN_PATH=
        export QT_XCB_GL_INTEGRATION=none
        source ~/.fishrc 2> /dev/null || true
      end
    '';
    # mount ~/.config/fish
    # mount ~/.config/git
    # mount ~/.cache/wal
    # mount ~/.config/starship.toml
    # mount ~/.nix-profile
    # mount ~/.ssh
  };

  config.programs = {
    fish = {
      enable = true;
      functions = {
        se = "e /sudo:root@localhost:(realpath $argv)";
      };
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
        ls = "exa";
        cat = "bat";

        sw = "sudo nixos-rebuild switch";
        nix-repl = "nix repl --expr 'import <nixpkgs> {}' --expr 'import <nixpkgs/nixos> {}'";

        ldm = "qdbus org.kde.ksmserver /KSMServer logout 0 3 3";

        work = "distrobox enter -r work --";
        arch = "distrobox enter -r arch --";
      };
      shellInit = ''
        set fish_greeting
        bind \cH backward-kill-word
        bind \e\[3\;5~ kill-word
        bind \e\[5C forward-word
        bind \e\[5D backward-word
        test -f /etc/fishrc && source /etc/fishrc
        # fish_add_path ~/.local/bin
        # cod init $fish_pid fish | source
      '';
      plugins = [
        {
          name = "nix-env";
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "a3c55307dce38c73485eac1f654c8f392341bda2";
            sha256 = "0k6l21j192hrhy95092dm8029p52aakvzis7jiw48wnbckyidi6v";
          };
        }
        {
          name = "fzf";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "fzf";
            rev = "479fa67d7439b23095e01b64987ae79a91a4e283";
            sha256 = "0k6l21j192hrhy95092dm8029p52aakvzis7jiw48wnbckyidi6v";
          };
        }
        {
          name = "z";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "z";
            rev = "45a9ff6d0932b0e9835cbeb60b9794ba706eef10";
            sha256 = "1kjyl4gx26q8175wcizvsm0jwhppd00rixdcr1p7gifw6s308sd5";
          };
        }
        {
          name = "hydro";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "hydro";
            rev = "a5877e9ef76b3e915c06143630bffc5ddeaba2a1";
            sha256 = "1lgknykah265wxx6wyy5pqc3w3jhkr2nnybwb4954nlklr12g7ww";
          };
        }
      ];
    };
    starship = {
      enable = true;
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
