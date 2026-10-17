# nix-config

ahggns home-manager modules, plus the machines that consume them. Architecture: `AGENTS.md`.

## Commands

| Command | Does |
|---|---|
| `nix run .` | build + activate home (standalone home-manager, no sudo) |
| `nix run .#system` | build + activate nix-darwin: nix.conf, Homebrew, Dock (sudo) |
| `nix build .` / `nix build .#system` | build only (`./result`) |
| `nix flake check --all-systems` | evaluate every module alone, on every system |
| `~/.local/state/nix/profiles/home-manager-<N>-link/activate` | home rollback |
| `sudo darwin-rebuild --rollback` | system rollback |
| `nix fmt -- <files>` | nixfmt |
| `nix run nixpkgs#statix -- check .` / `nix run nixpkgs#deadnix -- .` | lint |
| `nix flake update [input]` | bump pins |
| `dockutil --list` | re-derive `dock.entries` |

Review Homebrew changes before switching after a cask edit: `sudo darwin-rebuild check --flake .#default`.

## New Mac

Prereqs: Xcode CLT (run any `git`), an ssh-agent key GitHub accepts.

```bash
git clone git@github.com:ahggns/nix-config.git ~/src/ahggns/nix-config
cd ~/src/ahggns/nix-config && scripts/bootstrap.sh
```

| bootstrap step | Why |
|---|---|
| install Nix | official multi-user installer |
| move `/etc/zshrc`, `/etc/bashrc` aside | nix-darwin won't overwrite unrecognized files |
| move unmanaged Homebrew `Library/Taps` aside (asks) | nix-homebrew owns it as a symlink |
| move a symlinked `~/.zshenv` aside | home-manager can't back up symlinks |
| `nix run .#system`, then `nix run .` | first switch |

## Downstream

| Export | Use |
|---|---|
| `homeManagerModules.{terminal,theme,shell,git,editor}` | configure apps you enable; never enable anything |
| `homeManagerModules.apps` / `.default` | this machine's app set / everything (needs the private `think` input) |
| `darwinModules.{nix,user,homebrew,dock,default}` | nix.conf, primary user, nix-homebrew (when `homebrew.enable`), Dock (when `dock.enable`) |
| `lib.mkSwitchApp pkgs out` | `nix run` app activating a home-manager or nix-darwin build |
| `apps.aarch64-darwin.bootstrap` | first switch (system, then home) of the flake in `$PWD` |
| `packages.<system>.gw`, `overlays.default` | `gw`: run the nearest `gradlew` up the tree |
| `templates.downstream` | starter consumer flake, see `docs/downstream.md` |

| Module | Covers | Options |
|---|---|---|
| `terminal` | kitty, alacritty, ghostty, tmux | `terminal.font.{name,package,size}` |
| `theme` | alacritty, kitty, ghostty, tmux, neovim, fzf, vscode, cursor, cmux, starship | `theme.name`, `theme.palette.base00`…`base0F` |
| `shell` | zsh, aliases, history, completion, env, prompt, direnv | `shell.prompt.default`, `shell.zsh.snippets.<name>` |
| `git` | aliases, fsmonitor, lfs | — |
| `editor` | neovim, vscode, cursor | — |

Consumer flake layout and rules: [`docs/downstream.md`](docs/downstream.md).
