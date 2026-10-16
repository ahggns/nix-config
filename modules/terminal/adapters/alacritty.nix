{ config, lib, ... }:

let
  ah = import ../../lib.nix { inherit lib; };
  font = config.terminal.font;
in
{
  config = lib.mkIf (ah.enabled config "alacritty") {
    home.packages = lib.optional (font.package != null) font.package;
    programs.alacritty.settings.font = ah.defaults {
      normal = {
        family = font.name;
        style = "Regular";
      };
      inherit (font) size;
    };
  };
}
