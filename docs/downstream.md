# Downstream flakes

Source of truth: [`templates/downstream/`](../templates/downstream), evaluated by `checks.aarch64-darwin.template-downstream`.

## New machine

Prereqs: Nix (official installer), Xcode CLT.

```bash
mkdir -p ~/src/work-nix && cd ~/src/work-nix
nix flake init -t github:ahggns/nix-config#downstream
# edit: flake.nix user, home/overrides/git.nix identity
git init && git add -A
nix run github:ahggns/nix-config#bootstrap
```

After that: `nix run .` to switch, `nix flake update ahggns` for new defaults.

## Layout

```
flake.nix                 inputs; user; darwinConfigurations.default; packages/apps.default
darwin/default.nix        ahggns.darwinModules.default; primaryUser; fonts; HM wiring
home/default.nix          ahggns HM modules + ./apps + ./overrides + ./modules
home/apps/default.nix     programs.<x>.enable, home.packages    (the only file that enables)
home/overrides/           one file per ahggns module overridden
home/modules/             machine-local modules (example: awscli.nix)
```

| Layer | Role | Mirrors in ahggns |
|---|---|---|
| ahggns modules | configure enabled apps, `mkDefault` values | `modules/*` |
| `home/apps/` | decide what's enabled and installed | `modules/apps` |
| `home/overrides/` | plain assignments over ahggns defaults | — |
| `home/modules/` | config for apps ahggns doesn't cover | adapters |
| `darwin/` | system level | `darwin/` |

## Opt-ins

| Want | Add |
|---|---|
| Terminal emulator | `programs.kitty.enable = true;` (or alacritty, ghostty) in `home/apps` |
| VS Code / Cursor | `programs.vscode.enable = true;` + allow unfree in `darwin/` |
| Homebrew casks | `homebrew = { enable = true; casks = [ ... ]; };` in `darwin/` |
| Managed Dock | `dock = { enable = true; entries = [ ... ]; };` in `darwin/` |
| starship prompt | `programs.starship.enable = true;` + `shell.prompt.default = "starship";` |
| Another palette | `theme.palette.base0C = "#…";` or `theme.name` + all 16 slots |
| Drop a `.zshrc` piece | `shell.zsh.snippets.<name>.text = "";` |

## Rules

| Rule | Why |
|---|---|
| Enable only in `home/apps/` | ahggns modules never enable |
| Override with plain assignment | every ahggns default is `mkDefault` |
| Local modules gate on `enable`, use `mkDefault` | same contract as ahggns |
| Skip `homeManagerModules.apps`/`.default` | personal app set; pulls the private `think` input |
