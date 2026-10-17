{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../lib.nix { inherit lib; };
  cfg = config.shell.zsh;
  snippet = order: text: {
    order = lib.mkDefault order;
    text = lib.mkDefault text;
  };
in
{
  options.shell.zsh.snippets = lib.mkOption {
    description = "Named .zshrc pieces at mkOrder `order`; blank `text` to drop one.";
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          order = lib.mkOption {
            type = lib.types.int;
            default = 1000;
          };
          text = lib.mkOption { type = lib.types.lines; };
        };
      }
    );
  };

  config = lib.mkIf (ah.enabled config "zsh") {
    xdg.enable = lib.mkDefault true;

    home = {
      sessionVariables = ah.defaults (
        {
          EDITOR = "vi";
          VISUAL = "vi";
        }
        // lib.optionalAttrs (ah.enabled config "neovim") {
          EDITOR = "nvim";
          VISUAL = "nvim";
          VIMCONFIG = "$HOME/.config/nvim";
          MANPAGER = "nvim +Man!";
        }
      );
      sessionPath = [ "$HOME/.local/bin" ];
    };

    programs.zsh = {
      # dotfiles in $HOME, not $XDG_CONFIG_HOME/zsh
      dotDir = lib.mkDefault config.home.homeDirectory;

      enableCompletion = lib.mkDefault false; # compinit runs in zsh/completion.zsh
      syntaxHighlighting.enable = lib.mkDefault true;

      history = ah.defaults {
        size = 100000;
        save = 100000;
        extended = true;
        ignoreDups = true;
        ignoreAllDups = true;
        findNoDups = true;
        ignoreSpace = true;
        saveNoDups = true;
      };

      envExtra = lib.optionalString pkgs.stdenv.isLinux "export TERM='xterm' ";

      shellAliases = ah.defaults {
        ls = "ls --color=auto";
        l = "ls -l";
        ll = "ls -lahF";
        lls = "ls -lahFtr";
        la = "ls -A";
        lc = "ls -CF";

        cp = "cp -iv";
        mv = "mv -iv";
        rm = "rm -iv";

        svim = "sudoedit";
        dvim = "vim -u /usr/share/nvim/archlinux.vim";
        nvimc = "rm -I $VIMCONFIG/swap/*";
        nvimcu = "rm -I $VIMCONFIG/undo/*";
        nviml = ''nvim -w $VIMCONFIG/vimlog "$@"'';
        nvimd = "nvim --noplugin -u NONE";
        nvimfr = ''nvim +e /tmp/scratchpad.md -c "set spelllang=fr"'';
        lvim = ''\vim -c "set nowrap|syntax off"'';
      };

      initContent = lib.mkMerge (
        lib.mapAttrsToList (_: s: lib.mkOrder s.order s.text) (
          lib.filterAttrs (_: s: s.text != "") cfg.snippets
        )
      );
    };

    # 950-990: ahead of home-manager's 1000-order hooks; prompt dispatcher is mkAfter
    shell.zsh.snippets = {
      homebrew = snippet 950 (
        lib.optionalString pkgs.stdenv.isDarwin ''
          if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            # nix-managed tools win over formulae of the same name
            path=(''${path:#/opt/homebrew/(bin|sbin)} /opt/homebrew/bin /opt/homebrew/sbin)
          fi
        ''
      );

      # before completion.zsh, which snapshots LS_COLORS
      dircolors = snippet 955 ''
        eval "$(${pkgs.coreutils}/bin/dircolors -b ${./zsh/colors/nord-dircolors})"
      '';

      completion = snippet 960 ''
        fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
        source ${./zsh/completion.zsh}
      '';

      vimMode = snippet 965 ''
        bindkey -v; export KEYTIMEOUT=1
        source ${./zsh/plugins/vim-mode}
        source ${./zsh/plugins/cursor_mode}
      '';

      # after vimMode
      bindings = snippet 970 ''
        source ${./zsh/bindings.zsh}
      '';

      title = snippet 975 ''
        precmd() {
            echo -ne "\033]0;''${PWD##*/}\007"
        }
      '';

      history = snippet 980 ''
        setopt HIST_REDUCE_BLANKS
        setopt HIST_VERIFY
      '';

      local = snippet 990 ''
        [ -f "$HOME/.zshrc_local" ] && source "$HOME/.zshrc_local"
      '';
    };

    programs.direnv.nix-direnv.enable = lib.mkIf (ah.enabled config "direnv") (lib.mkDefault true);
  };
}
