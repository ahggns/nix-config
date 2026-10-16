{ self, ... }:

{
  imports = [ self.homeManagerModules.default ];

  home.stateVersion = "26.05";

  programs.git.settings.user = {
    name = "Andrew Higgins";
    email = "ahiggins8434@gmail.com";
  };
}
