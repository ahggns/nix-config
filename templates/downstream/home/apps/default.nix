# the only file that enables anything
{ pkgs, ... }:

{
  programs = {
    zsh.enable = true;
    git.enable = true;
    neovim.enable = true;
    fzf.enable = true;
    direnv.enable = true;
    tmux.enable = true;
  };

  home.packages = with pkgs; [
    coreutils
    jq
    ripgrep
    gh
    gw
  ];
}
