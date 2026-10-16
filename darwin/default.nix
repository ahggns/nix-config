{
  self,
  user,
  pkgs,
  lib,
  ...
}:

{
  imports = [ self.darwinModules.default ];

  system = {
    stateVersion = 7;
    primaryUser = user;
    defaults.dock = {
      autohide = true;
      tilesize = 68;
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    let
      allowedUnfreePrefixes = [
        "claude-"
        "vscode"
        "spotify"
        "terraform"
      ];
    in
    pkg: lib.any (prefix: lib.hasPrefix prefix (lib.getName pkg)) allowedUnfreePrefixes;

  fonts.packages = [ pkgs.meslo-lgs-nf ];

  homebrew = {
    enable = true;
    casks = [
      "sublime-text"
      "steam"
    ];
  };

  # re-derive: dockutil --list
  dock = {
    enable = true;
    entries = [
      { path = "/System/Applications/Apps.app"; }
      { path = "/System/Applications/System Settings.app"; }
      { path = "/Users/${user}/Applications/Home Manager Apps/Spotify.app"; }
      {
        path = "/Users/${user}/Downloads";
        section = "others";
      }
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit self; };
    users.${user} = {
      imports = [ ../home.nix ];
      home = {
        username = user;
        homeDirectory = "/Users/${user}";
      };
    };
  };
}
