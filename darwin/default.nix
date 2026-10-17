{ self, user, ... }:

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
}
