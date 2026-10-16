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
  n = t.named;
in
{
  config = lib.mkIf (ah.enabled config "alacritty") {
    programs.alacritty.settings.colors = ah.defaults {
      primary = {
        foreground = p.base05;
        background = p.base00;
        bright_foreground = p.base07;
      };
      selection = {
        text = p.base05;
        background = p.base02;
      };
      cursor = {
        text = p.base00;
        cursor = p.base05;
      };
      normal = {
        inherit (n)
          black
          red
          green
          yellow
          blue
          magenta
          cyan
          white
          ;
      };
      bright = {
        black = n.bright-black;
        white = n.bright-white;
        inherit (n)
          red
          green
          yellow
          blue
          magenta
          cyan
          ;
      };
    };
  };
}
