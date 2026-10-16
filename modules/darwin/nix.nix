# assumes the official installer; Determinate needs nix.enable = false
{ lib, ... }:

{
  nix = {
    enable = lib.mkDefault true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # setting substituters replaces nix's default list
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };
}
