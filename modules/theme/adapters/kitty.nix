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
  config = lib.mkIf (ah.enabled config "kitty") {
    programs.kitty.settings = ah.defaults (
      {
        foreground = p.base05;
        background = p.base00;
        selection_foreground = p.base05;
        selection_background = p.base02;
        cursor = p.base05;
        cursor_text_color = p.base00;
        url_color = p.base04;
        active_border_color = p.base03;
        inactive_border_color = p.base01;

        tab_bar_background = p.base01;
        active_tab_background = p.base0C;
        active_tab_foreground = p.base00;
        inactive_tab_background = p.base01;
        inactive_tab_foreground = p.base04;
      }
      // lib.listToAttrs (lib.imap0 (i: c: lib.nameValuePair "color${toString i}" c) t.ansi)
    );
  };
}
