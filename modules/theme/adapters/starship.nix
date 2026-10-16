{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../../lib.nix { inherit lib; };
  t = (import ../lib.nix { inherit lib pkgs; }).resolve config.theme;
  n = t.named;
in
{
  config = lib.mkIf (ah.enabled config "starship") {
    programs.starship.settings = ah.defaults {
      palette = "base16";
      palettes.base16 =
        n
        // {
          purple = n.magenta;
          bright-purple = n.magenta;
          bright-magenta = n.magenta;
          bright-red = n.red;
          bright-green = n.green;
          bright-yellow = n.yellow;
          bright-blue = n.blue;
          bright-cyan = n.cyan;
        }
        // t.palette;
    };
  };
}
