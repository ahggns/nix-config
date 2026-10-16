{ lib, pkgs, ... }:

let
  ah = import ../lib.nix { inherit lib; };
  inherit (pkgs.stdenv) isDarwin;
  on = lib.mkDefault true;
in
{
  imports = [
    ../programs/cmux.nix
    ./claude-code.nix
  ];

  programs = {
    zsh.enable = on;
    neovim.enable = on;
    git.enable = on;
    fzf.enable = on;
    direnv.enable = on;
    starship.enable = on;
    oh-my-posh.enable = on;
    kitty.enable = on;
    alacritty.enable = on;
    vscode.enable = on;

    # no darwin build; config generator for cmux
    ghostty = lib.mkIf isDarwin {
      enable = on;
      package = lib.mkDefault null;
    };
    cmux.enable = lib.mkIf isDarwin on;
  };

  home = {
    packages =
      (with pkgs; [
        coreutils
        jq
        silver-searcher-ng
        ripgrep
        nodejs
        openjdk21
        python3
        gradle
        uv
        terraform
        docker
        gh
        claude-code
        (callPackage ../../pkgs/gw.nix { })
      ])
      ++ lib.optionals isDarwin [
        pkgs.colima
        pkgs.utm
        pkgs.spotify
        (pkgs.callPackage ./claude-desktop.nix { })
      ];

    sessionVariables = ah.defaults {
      DOTFILES = "$HOME/src/ahggns/nix-config";
      WORKSPACE = "$HOME/workspace";
    };

    sessionPath = lib.optionals isDarwin [
      "/Applications/Sublime Text.app/Contents/SharedSupport/bin"
      "/Applications/Xcode.app/Contents/MacOS"
      "/Applications/IntelliJ IDEA CE.app/Contents/MacOS"
      "/opt/homebrew/opt/libpq/bin"
    ];
  };
}
