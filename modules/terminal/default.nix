{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../lib.nix { inherit lib; };
in
{
  imports = ah.importDir ./adapters;

  options.terminal.font = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "MesloLGS NF";
      description = "Monospace family for every enabled terminal.";
    };
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.meslo-lgs-nf;
      defaultText = lib.literalExpression "pkgs.meslo-lgs-nf";
      description = "Package providing the font; null if installed elsewhere.";
    };
    size = lib.mkOption {
      type = lib.types.number;
      default = 12;
      description = "Points at 96dpi; 72dpi emulators are scaled.";
    };
  };

  config.home.packages = lib.optional (
    config.terminal.font.package != null
  ) config.terminal.font.package;
}
