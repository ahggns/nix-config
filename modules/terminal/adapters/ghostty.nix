{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../../lib.nix { inherit lib; };
  font = config.terminal.font;
in
{
  config = lib.mkIf (ah.enabled config "ghostty") {
    home.packages = lib.optional (font.package != null) font.package;
    programs.ghostty.settings = ah.defaults {
      font-family = font.name;
      # 72dpi on darwin
      font-size = if pkgs.stdenv.hostPlatform.isDarwin then font.size * 4.0 / 3.0 else font.size;
      shell-integration = "detect";
    };
  };
}
