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
  config = lib.mkIf (ah.enabled config "fzf") {
    programs.fzf.colors = ah.defaults {
      "bg" = p.base00;
      "bg+" = p.base01;
      "fg" = p.base04;
      "fg+" = p.base06;
      "header" = p.base0D;
      "hl" = p.base0D;
      "hl+" = p.base0D;
      "info" = p.base0A;
      "marker" = p.base0C;
      "pointer" = p.base0C;
      "prompt" = p.base0A;
      "spinner" = p.base0C;
    };
  };
}
