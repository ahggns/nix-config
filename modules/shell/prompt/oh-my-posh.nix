{ lib, config, ... }:

let
  ah = import ../../lib.nix { inherit lib; };
  omp = config.programs.oh-my-posh;
  theme = omp.useTheme;
  themeFile = "${omp.package}/share/oh-my-posh/themes/${theme}.omp.json";
in
{
  config = lib.mkIf (ah.enabled config "zsh" && ah.enabled config "oh-my-posh") {
    programs.oh-my-posh = {
      # dispatcher owns activation
      enableZshIntegration = lib.mkDefault false;
      useTheme = lib.mkDefault "nordtron";
    };

    shell.prompt.inits.oh-my-posh = ''
      eval "$(${lib.getExe omp.package} init zsh --config ${themeFile})"
    '';
  };
}
