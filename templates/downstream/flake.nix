{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ahggns = {
      url = "github:ahggns/nix-config";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "nix-darwin";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      ahggns,
      ...
    }:
    let
      system = "aarch64-darwin";
      user = "jdoe";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ahggns.overlays.default ];
      };
      mac = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit ahggns user; };
        modules = [ ./darwin ];
      };
      home = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit ahggns; };
        modules = [
          ./home
          {
            home = {
              username = user;
              homeDirectory = "/Users/${user}";
            };
          }
        ];
      };
    in
    {
      darwinConfigurations.default = mac;
      homeConfigurations.default = home;
      packages.${system} = {
        default = home.activationPackage;
        inherit (mac) system;
      };
      apps.${system} = {
        default = ahggns.lib.mkSwitchApp pkgs home.activationPackage;
        system = ahggns.lib.mkSwitchApp pkgs mac.system;
      };
    };
}
