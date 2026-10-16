{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../../lib.nix { inherit lib; };
in
{
  config = lib.mkIf (ah.enabled config "zsh") {
    shell.prompt.inits.pure = ''
      fpath+=(${pkgs.pure-prompt}/share/zsh/site-functions)
      autoload -Uz promptinit && promptinit
      prompt pure
    '';
  };
}
