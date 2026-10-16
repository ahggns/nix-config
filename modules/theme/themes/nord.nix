# native ports apply only while theme.palette is unmodified
{ pkgs }:

{
  palette = {
    base00 = "#2e3440";
    base01 = "#3b4252";
    base02 = "#434c5e";
    base03 = "#4c566a";
    base04 = "#d8dee9";
    base05 = "#e5e9f0";
    base06 = "#eceff4";
    base07 = "#8fbcbb";
    base08 = "#bf616a";
    base09 = "#d08770";
    base0A = "#ebcb8b";
    base0B = "#a3be8c";
    base0C = "#88c0d0";
    base0D = "#81a1c1";
    base0E = "#b48ead";
    base0F = "#5e81ac";
  };

  native = {
    neovim = {
      plugin = pkgs.vimPlugins.gbprod-nord;
      lua = ''
        require('nord').setup({})
        vim.cmd.colorscheme('nord')
      '';
      # not base16_nord: shifted slots
      airline = "nord_minimal";
    };

    vscode = {
      colorTheme = "Nord";
      extension = pkgs.vscode-extensions.arcticicestudio.nord-visual-studio-code;
    };
  };
}
