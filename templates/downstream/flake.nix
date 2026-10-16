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
      mac = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit ahggns user; };
        modules = [
          home-manager.darwinModules.home-manager
          ./darwin
        ];
      };
    in
    {
      darwinConfigurations.default = mac;
      packages.${system}.default = mac.system;
      apps.${system}.default = ahggns.lib.mkSwitchApp nixpkgs.legacyPackages.${system} mac.system;
    };
}
