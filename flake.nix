{
  description = "ahggns defaults as importable home-manager modules (terminal, theme, shell, git, editor, apps), plus the personal machines that consume them";

  # nix run .    build + activate
  # nix build .  build only

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    # pinned for nix-homebrew mutableTaps = false
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    think = {
      url = "git+ssh://git@github.com/ahggns/think.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      think,
      ...
    }:
    let
      user = "ahiggins";

      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      vendoredZshFiles = [
        ./modules/shell/zsh/bindings.zsh
        ./modules/shell/zsh/completion.zsh
        ./modules/shell/zsh/plugins/vim-mode
        ./modules/shell/zsh/plugins/cursor_mode
        ./modules/shell/zsh/prompts/p10k-config.zsh
      ];

      # think bound here: no specialArgs for consumers; skipping apps never fetches it
      appsModule =
        { pkgs, ... }:
        {
          key = "ahggns/modules/apps";
          _file = ./flake.nix;
          imports = [ ./modules/apps ];
          home.packages = [ think.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        };

      # instantiate only: each module alone, and with every adapted app enabled
      moduleEvalChecks =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          inherit (pkgs) lib;
          base = {
            home = {
              username = "check";
              homeDirectory = if pkgs.stdenv.isDarwin then "/Users/check" else "/home/check";
              stateVersion = "26.05";
            };
          };
          everyApp = {
            imports = [
              ./modules/programs/cmux.nix
            ];
            programs =
              lib.genAttrs
                [
                  "zsh"
                  "neovim"
                  "git"
                  "fzf"
                  "direnv"
                  "starship"
                  "oh-my-posh"
                  "tmux"
                  "kitty"
                  "alacritty"
                  "vscode"
                  "cursor"
                ]
                (_: {
                  enable = true;
                })
              // {
                ghostty = {
                  enable = true;
                }
                // lib.optionalAttrs pkgs.stdenv.isDarwin { package = null; };
              }
              // lib.optionalAttrs pkgs.stdenv.isDarwin {
                cmux.enable = true;
              };
          };
          evalOnly =
            name: modules:
            let
              hm = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ base ] ++ modules;
              };
            in
            pkgs.writeText "hm-eval-${name}" (builtins.unsafeDiscardStringContext hm.activationPackage.drvPath);
          reusable = removeAttrs self.homeManagerModules [
            "apps"
            "default"
          ];
        in
        lib.concatMapAttrs (name: m: {
          "hm-${name}" = evalOnly name [ m ];
          "hm-${name}-every-app" = evalOnly "${name}-every-app" [
            m
            everyApp
          ];
        }) reusable
        // lib.optionalAttrs (system == "aarch64-darwin") {
          template-downstream = pkgs.writeText "template-downstream" (
            builtins.unsafeDiscardStringContext
              ((import ./templates/downstream/flake.nix).outputs {
                inherit nixpkgs nix-darwin home-manager;
                ahggns = self;
              }).darwinConfigurations.default.system.drvPath
          );
        }
        // {
          hm-default = evalOnly "default" [ self.homeManagerModules.default ];
          hm-theme-custom-palette = evalOnly "theme-custom-palette" [
            self.homeManagerModules.theme
            everyApp
            { theme.palette.base0C = "#8fbcbb"; }
          ];
        };

      mac = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit self user; };
        modules = [
          home-manager.darwinModules.home-manager
          ./darwin
        ];
      };

      linuxHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit self; };
          modules = [
            ./home.nix
            {
              home = {
                username = user;
                homeDirectory = "/home/${user}";
              };
            }
          ];
        };

      machine = {
        aarch64-darwin = mac.system;
      }
      // nixpkgs.lib.genAttrs linuxSystems (system: (linuxHome system).activationPackage);
      systems = builtins.attrNames machine;

      mkSwitchApp = pkgs: machine: {
        type = "app";
        program = "${pkgs.writeShellScript "switch" "exec ${
          pkgs.writeShellApplication {
            name = "switch";
            text = builtins.readFile ./scripts/switch.sh;
          }
        }/bin/switch ${machine}"}";
        meta.description = "Build and activate this machine";
      };
    in
    {
      formatter = nixpkgs.lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      packages = nixpkgs.lib.genAttrs systems (system: {
        default = machine.${system};
        gw = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/gw.nix { };
      });

      overlays.default = final: _: {
        gw = final.callPackage ./pkgs/gw.nix { };
      };

      apps = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = mkSwitchApp pkgs machine.${system};
        }
        // nixpkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
          bootstrap = {
            type = "app";
            program = nixpkgs.lib.getExe (
              pkgs.writeShellApplication {
                name = "bootstrap";
                text = builtins.readFile ./scripts/bootstrap.sh;
              }
            );
            meta.description = "First nix-darwin switch of the flake in $PWD";
          };
        }
      );

      lib = { inherit mkSwitchApp; };

      darwinModules = {
        nix = ./modules/darwin/nix.nix;
        user = ./modules/darwin/user.nix;
        dock = ./modules/darwin/dock.nix;
        homebrew = {
          key = "ahggns/modules/darwin/homebrew";
          _file = ./flake.nix;
          imports = [
            nix-homebrew.darwinModules.nix-homebrew
            (import ./modules/darwin/homebrew.nix {
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
            })
          ];
        };
        default = {
          imports = map (name: self.darwinModules.${name}) [
            "nix"
            "user"
            "dock"
            "homebrew"
          ];
        };
      };

      checks = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        moduleEvalChecks system
        // {
          zsh-syntax = pkgs.runCommand "zsh-syntax-check" { } ''
            ${pkgs.lib.concatMapStringsSep "\n" (f: "${pkgs.zsh}/bin/zsh -n ${f}") vendoredZshFiles}
            touch $out
          '';
        }
      );

      homeManagerModules = {
        terminal = ./modules/terminal;
        theme = ./modules/theme;
        shell = ./modules/shell;
        git = ./modules/git;
        editor = ./modules/editor;
        apps = appsModule;
        default = {
          imports = with self.homeManagerModules; [
            terminal
            theme
            shell
            git
            editor
            apps
          ];
        };
      };

      templates.downstream = {
        path = ./templates/downstream;
        description = "A machine that consumes the ahggns home-manager modules and brings its own apps";
      };

      darwinConfigurations.default = mac;
    };
}
