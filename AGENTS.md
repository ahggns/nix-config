# AGENTS.md

Nix flake publishing ahggns defaults as home-manager modules (`homeManagerModules.*`), plus this repo's own machines (one Mac via nix-darwin, Linux via standalone home-manager). The machines consume the modules exactly as a downstream flake would.

## Commands

| Task | Command |
|---|---|
| Verify (run before declaring done) | `nix flake check --all-systems` |
| Build this machine, no activation | `nix build .` |
| Build + activate (needs sudo on darwin; ask the user first) | `nix run .` |
| Format touched files | `nix fmt -- <files>` |
| Lint | `nix run nixpkgs#statix -- check .` and `nix run nixpkgs#deadnix -- .` |
| Shell scripts | `nix run nixpkgs#shellcheck -- scripts/*.sh` |
| Inspect generated dotfiles | `nix build .#darwinConfigurations.default.config.home-manager.users.ahiggins.home-files --no-link --print-out-paths` |
| Diff closures before/after | `nix store diff-closures <old> <new>` |

New files must be `git add`ed before any `nix` command sees them (flakes only see tracked files; untracked = eval error).

For a behavior-preserving refactor, build the home-files before and after and `diff -r` them; build against `HEAD` with `"git+file://$PWD?rev=$(git rev-parse HEAD)#..."`.

## Layout

```
flake.nix                outputs; `machine` per system; `switch` app; eval checks
home.nix                 personal HM config: homeManagerModules.default + git identity
darwin/default.nix       this Mac: darwinModules.default + casks, Dock entries, fonts, unfree, HM wiring
modules/lib.nix          ah.defaults · ah.importDir · ah.enabled
modules/programs/        enable/package shims for apps without an HM module (cmux)
modules/darwin/          darwinModules: nix.nix, user.nix, homebrew.nix (gated on homebrew.enable), dock.nix (dock.*)
modules/terminal/        terminal.font.*; adapters/ per emulator
modules/theme/           theme.name, theme.palette; adapters/ per app; themes/ stock palettes; lib.nix resolve
modules/shell/           zsh.nix (snippets, aliases, history, env); prompt/ (dispatcher); zsh/ (vendored files)
modules/git/             git defaults, no identity
modules/editor/          neovim/ (init.lua, config.vim), vscode.nix (VS Code + Cursor)
modules/apps/            the ONLY module that enables apps; packages; claude-desktop derivation
pkgs/                    programs this repo defines (gw); exported as packages.<system>.* + overlays.default
scripts/                 bootstrap.sh (also apps.<darwin>.bootstrap), switch.sh (lib.mkSwitchApp), cmux activation
templates/downstream/    nix-darwin consumer flake (core CLI + tmux); evaluated by checks.template-downstream
docs/downstream.md       consumer layout + rules; keep in sync with the template
```

## Invariants for `modules/{terminal,theme,shell,git,editor,darwin}`

These are enforced by `checks` (each module evaluated alone, with every adapted app enabled, and with a non-stock palette). Breaking one fails `nix flake check`.

1. **Never enable an app.** Wrap config in `lib.mkIf (ah.enabled config "<program>")`. Only `modules/apps` sets `programs.<x>.enable`.
2. **Scalars are `mkDefault`.** Use `ah.defaults { ... }` for settings attrsets. Do not `mkDefault` lists or `lines` (`home.packages`, `plugins`, `initLua`, `initContent`): a downstream addition would replace them. Pieces a consumer may need to remove become named options (`shell.zsh.snippets.<name>`, `shell.prompt.inits.<name>`).
3. **No cross-module imports.** Read another module's options only softly: `config.terminal.font.name or null`.
4. **New app = one file** in `adapters/` (auto-imported by `ah.importDir`). If home-manager has no `programs.<x>`, add a shim in `modules/programs/` and import it from each adapter that needs it.
5. **No usernames, hostnames, emails, absolute home paths.** Use `config.home.homeDirectory` or `$HOME` in shell strings. Identity belongs in `home.nix`.
6. **Branch on values, never on attrset shape.** `config = if config.theme... then {a} else {b}` causes infinite recursion; put the conditional inside the value.

## Theme specifics

- `theme.palette.baseXX` defaults from `modules/theme/themes/<theme.name>.nix`. A name with no file must set all 16 slots.
- `native` ports (nord.nvim, the Nord VS Code extension) apply only while the palette equals stock (`isStock`); otherwise adapters derive from the palette (mini.base16; VS Code Modern + `colorCustomizations`).
- ANSI mapping, named colors, polarity, and float channels come from `resolve` in `modules/theme/lib.nix`; adapters must not re-derive them.
- cmux is *merged into* (jq), never owned, because cmux rewrites its own config file. Keep the merges idempotent and no-op when unchanged.

## zsh init ordering

`programs.zsh.initContent` only (not `initExtra`). Orders: p10k instant prompt `mkBefore` → `shell.zsh.snippets` 950–990 → home-manager hooks and other content at 1000 → prompt dispatcher `mkAfter`. Prompts with an HM module set `enableZshIntegration = mkDefault false`; the dispatcher owns activation.

## Conventions

- Config in a non-Nix language is a real file read with `builtins.readFile` (`init.lua`, `config.vim`, `scripts/*.sh`), not an embedded string. Scripts get data through arguments, not interpolation.
- Custom derivations live in their own file, called via `pkgs.callPackage`, with a one-line bump command in a header comment. Programs meant for consumers go in `pkgs/` and get a `packages`/`overlays.default` entry.
- `docs/downstream.md` describes `templates/downstream/`; update both together.
- Unfree packages need their name prefix added to the allowlist in `darwin/default.nix`.
- `homebrew.onActivation.cleanup = "none"`; don't change to `"zap"` without the user.
- `nix.enable = true` assumes the official Nix installer.
- Copy (comments, READMEs) is terse, present-state only, and uses tables over prose. Comments only for non-obvious invariants; prefer clear code. This file is exempt.

## Gotchas

- In `flake.nix`, `with self.<x>Modules; [ user ]` resolves `user` to the `let` binding, not the module (`with` loses to lexical scope). Reference modules explicitly.
- `modules/darwin` follows the same rules: Homebrew only when `homebrew.enable`, Dock only when `dock.enable`; nothing reads a username except via `config.system.primaryUser`.
- `ah.defaults` treats derivations as leaves; packages inside settings are safe.
- Building an output that reads a derivation's contents at eval time (`builtins.readFile drv`) is IFD; hash strings instead.
- On Linux `programs.ghostty.package = null` fails (systemd unit needs it); the null is darwin-only.
- cmux is darwin-only; don't enable them in Linux evaluations.
- `nix flake check` without `--all-systems` skips the Linux checks.
- The `think` input is private (`git+ssh`); evaluating `apps`/`default` needs the user's SSH agent. Never run flake evaluation as root.

## Not done

Terminal keybindings · tmux not enabled anywhere (theme adapter only) · statix/deadnix not in `checks` · no CI · Linux never run on hardware.
