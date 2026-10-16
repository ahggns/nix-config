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
  config = lib.mkIf (ah.enabled config "ghostty") {
    programs.ghostty = {
      themes.${t.name} = ah.defaults {
        background = p.base00;
        foreground = p.base05;
        cursor-color = p.base05;
        selection-background = p.base02;
        selection-foreground = p.base05;
        palette = lib.imap0 (i: c: "${toString i}=${c}") t.ansi;
      };

      settings = ah.defaults {
        theme = t.name;
        split-divider-color = p.base03;
      };
    };
  };
}
