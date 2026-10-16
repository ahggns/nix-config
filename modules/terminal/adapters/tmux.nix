{ config, lib, ... }:

let
  ah = import ../../lib.nix { inherit lib; };
in
{
  config = lib.mkIf (ah.enabled config "tmux") {
    programs.tmux =
      ah.defaults {
        keyMode = "vi";
        mouse = true;
        # zsh vi-mode and nvim both need Esc unbuffered
        escapeTime = 0;
        baseIndex = 1;
        historyLimit = 100000;
        focusEvents = true;
        terminal = "tmux-256color";
      }
      // {
        extraConfig = ''
          set -as terminal-features ",*:RGB"
          set -g renumber-windows on
          bind '"' split-window -v -c "#{pane_current_path}"
          bind % split-window -h -c "#{pane_current_path}"
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R
        '';
      };
  };
}
