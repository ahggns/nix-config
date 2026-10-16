{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../../lib.nix { inherit lib; };
in
{
  config = lib.mkIf (ah.enabled config "neovim") {
    programs.neovim = {
      viAlias = lib.mkDefault true;
      vimAlias = lib.mkDefault true;

      plugins = with pkgs.vimPlugins; [
        (pkgs.callPackage ./vim-plist.nix { })
        vim-airline
        vim-airline-themes
        nerdtree
        nerdtree-git-plugin

        (nvim-treesitter.withPlugins (
          p: with p; [
            bash
            css
            dockerfile
            groovy
            hcl
            java
            javascript
            json
            kotlin
            lua
            markdown
            markdown_inline
            nix
            python
            regex
            toml
            tsx
            typescript
            vim
            vimdoc
            yaml
          ]
        ))
        nvim-lspconfig
        blink-cmp
        friendly-snippets

        telescope-nvim
        telescope-fzf-native-nvim
        plenary-nvim
        nvim-web-devicons

        conform-nvim
        gitsigns-nvim
        which-key-nvim

        snacks-nvim
        claudecode-nvim
      ];

      extraPackages = with pkgs; [
        basedpyright
        ruff
        typescript-language-server
        typescript
        jdt-language-server
        nil
        bash-language-server
        terraform-ls
        marksman
        vscode-langservers-extracted
        tailwindcss-language-server
        shfmt
        prettier
      ];

      extraConfig = builtins.readFile ./config.vim;
      initLua = builtins.readFile ./init.lua;
    };
  };
}
