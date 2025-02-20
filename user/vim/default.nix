{
  pkgs,
  lib,
  config,
  ...
}:
let
  shim = import ../pkgs/shim.nix { inherit pkgs; };
in {
  config = {
    xdg.configFile."nvim".source = ./nvim;
    programs.neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      vimdiffAlias = true;
      withRuby = false;
      withNodeJs = false;
      withPython3 = false;
      extraPackages = with pkgs; [
        nil
        sumneko-lua-language-server
        stylua
        uncrustify
        shellcheck
        alejandra
        gopls
        revive
        asmfmt
        ccls
        black
        shellcheck
        shfmt
        nodejs-18_x
        marksman
        nodePackages.prettier
        nodePackages.stylelint
        nodePackages.jsonlint
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        nodePackages.bash-language-server
        nodePackages.node2nix
      ];
      plugins = with pkgs.vimPlugins; [
        pywal-nvim
        vim-nix
        rust-tools-nvim
        crates-nvim
        null-ls-nvim

        # copilot-vim
        vim-fugitive
        lualine-nvim
        nvim-web-devicons
        bufferline-nvim
        diffview-nvim
        vim-better-whitespace
        telescope-file-browser-nvim

        impatient-nvim
        comment-nvim
        telescope-nvim
        nvim-web-devicons
        nvim-lspconfig
        lspkind-nvim
        hop-nvim

        nvim-cmp
        cmp-buffer
        cmp-path
        cmp-nvim-lsp
        cmp_luasnip
        luasnip
        friendly-snippets

        (nvim-treesitter.withPlugins (plugins:
          with plugins; [
            tree-sitter-python
            tree-sitter-c
            tree-sitter-nix
            tree-sitter-rust
            tree-sitter-toml
            tree-sitter-json
            tree-sitter-lua
            tree-sitter-go
            tree-sitter-java
            tree-sitter-typescript
            tree-sitter-javascript
            tree-sitter-cmake
            tree-sitter-comment
            tree-sitter-http
            tree-sitter-regex
            tree-sitter-make
            tree-sitter-html
            tree-sitter-css
            tree-sitter-dockerfile
          ]))
      ];
    };
  };
}