{ ahggns, ... }:

{
  imports = with ahggns.homeManagerModules; [
    terminal
    theme
    shell
    git
    editor
    ./apps
    ./overrides
    ./modules
  ];

  home.stateVersion = "26.05";
}
