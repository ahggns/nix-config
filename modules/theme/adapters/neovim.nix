{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../../lib.nix { inherit lib; };
  t = (import ../lib.nix { inherit lib pkgs; }).resolve config.theme;
  native = t.native.neovim or null;

  base16Lua = ''
    require('mini.base16').setup({
      palette = {
    ${lib.concatMapStringsSep "\n" (n: "    ${n} = '${t.palette.${n}}',") (lib.attrNames t.palette)}
      },
    })
  '';
in
{
  # branch on values, not attrset shape (infinite recursion)
  config = lib.mkIf (ah.enabled config "neovim") {
    programs.neovim = {
      plugins = [ (if native != null then native.plugin else pkgs.vimPlugins.mini-base16) ];
      initLua = lib.mkBefore (if native != null then native.lua else base16Lua);
      extraConfig = lib.optionalString (native != null && native ? airline) ''
        let g:airline_theme = '${native.airline}'
      '';
    };
  };
}
