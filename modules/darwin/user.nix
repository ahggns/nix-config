# home-manager's nix-darwin integration reads homeDirectory from users.users
{ config, lib, ... }:

let
  user = config.system.primaryUser;
in
{
  config = lib.mkIf (user != null) {
    users.users.${user} = {
      name = lib.mkDefault user;
      home = lib.mkDefault "/Users/${user}";
    };
  };
}
