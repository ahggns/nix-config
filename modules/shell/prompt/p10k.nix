{
  pkgs,
  lib,
  config,
  ...
}:

let
  ah = import ../../lib.nix { inherit lib; };
in
{
  config = lib.mkIf (ah.enabled config "zsh") {
    # instant prompt must precede all console output
    programs.zsh.initContent = lib.mkBefore ''
      if [[ "''${ZSH_PROMPT:-${config.shell.prompt.default}}" == p10k ]] &&
         [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    shell.prompt.inits.p10k = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${../zsh/prompts/p10k-config.zsh}
    '';
  };
}
