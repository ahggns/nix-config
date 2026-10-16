# taps are passed in by the flake (pinned inputs); active only when homebrew.enable
{ taps }:
{ config, lib, ... }:

{
  config = lib.mkIf config.homebrew.enable {
    homebrew = {
      onActivation = {
        autoUpdate = lib.mkDefault true;
        cleanup = lib.mkDefault "none";
      };
      taps = builtins.attrNames config.nix-homebrew.taps;
    };

    nix-homebrew = {
      enable = lib.mkDefault true;
      user = lib.mkDefault config.system.primaryUser;
      mutableTaps = lib.mkDefault false;
      inherit taps;
    };
  };
}
