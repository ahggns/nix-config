{ config, lib, ... }:

let
  ah = import ../../lib.nix { inherit lib; };
  font = config.terminal.font;
in
{
  config = lib.mkIf (ah.enabled config "kitty") {
    programs.kitty = {
      font = ah.defaults { inherit (font) name package size; };
      shellIntegration.enableZshIntegration = lib.mkDefault true;
      settings = ah.defaults {
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_separator = " ┇";
        tab_powerline_style = "slanted";
        active_tab_font_style = "bold";
        inactive_tab_font_style = "normal";
      };
    };
  };
}
