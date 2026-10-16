{
  ahggns,
  user,
  pkgs,
  ...
}:

{
  imports = [ ahggns.darwinModules.default ];

  system = {
    stateVersion = 7;
    primaryUser = user;
  };

  nixpkgs.overlays = [ ahggns.overlays.default ];

  # p10k glyphs, for whichever terminal is in use
  fonts.packages = [ pkgs.meslo-lgs-nf ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit ahggns; };
    users.${user} = {
      imports = [ ../home ];
      home = {
        username = user;
        homeDirectory = "/Users/${user}";
      };
    };
  };
}
