{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../lib.nix { inherit lib; };
  t = import ./lib.nix { inherit lib pkgs; };
  stock = t.themes.${config.theme.name} or null;
in
{
  imports = ah.importDir ./adapters;

  options.theme = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "nord";
      example = "gruvbox-dark";
      description = "Stock theme name (${lib.concatStringsSep ", " (lib.attrNames t.themes)}) or any name with a full palette.";
    };

    palette = lib.mkOption {
      description = "base16 slots; each defaults from the stock theme for theme.name.";
      default = { };
      type = lib.types.submodule {
        options = lib.genAttrs t.baseNames (
          slot:
          lib.mkOption {
            type = lib.types.strMatching "#[0-9a-fA-F]{6}";
            default =
              if stock != null then
                stock.palette.${slot}
              else
                throw "theme.palette.${slot} is unset, and theme.name = \"${config.theme.name}\" has no stock palette to default it from.";
            defaultText = lib.literalMD "the stock palette for `theme.name`";
          }
        );
      };
    };
  };
}
