{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../../lib.nix { inherit lib; };
  t = (import ../lib.nix { inherit lib pkgs; }).resolve config.theme;
  p = t.palette;
in
{
  config = lib.mkIf (ah.enabled config "tmux") {
    programs.tmux.extraConfig = ''
      set -g status-style "bg=${p.base01},fg=${p.base04}"
      set -g window-status-current-style "bg=${p.base0C},fg=${p.base00},bold"
      set -g pane-border-style "fg=${p.base02}"
      set -g pane-active-border-style "fg=${p.base0C}"
      set -g message-style "bg=${p.base02},fg=${p.base05}"
      set -g mode-style "bg=${p.base02},fg=${p.base05}"
      set -g clock-mode-colour "${p.base0D}"
    '';
  };
}
