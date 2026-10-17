{ ahggns, user, ... }:

{
  imports = [ ahggns.darwinModules.default ];

  system = {
    stateVersion = 7;
    primaryUser = user;
  };
}
