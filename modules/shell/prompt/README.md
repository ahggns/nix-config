# prompt

Active when `programs.zsh.enable`.

| Option | Type | Default |
|---|---|---|
| `shell.prompt.default` | str | `"p10k"` |
| `shell.prompt.inits.<name>` | lines (internal) | one per registered prompt |

| Prompt | Registered when | Colors | Git state |
|---|---|---|---|
| p10k | always | terminal ANSI | gitstatus daemon |
| pure | always | terminal ANSI | `git` per prompt |
| starship | `programs.starship.enable` | theme module palette | `git` per prompt (fsmonitor) |
| oh-my-posh | `programs.oh-my-posh.enable` | `useTheme` (`nordtron`) | `git` per prompt |

`ZSH_PROMPT=<name> zsh` overrides the default for one shell. Unknown names warn and leave `PROMPT` alone; an unknown `default` fails evaluation.

## `.zshrc` order

| Order | Source |
|---|---|
| `mkBefore` | `p10k.nix` instant prompt (must precede any output) |
| 950–990 | `shell.zsh.snippets` |
| 1000 | home-manager hooks (kitty, ghostty, direnv), other `initContent` |
| `mkAfter` | dispatcher (`default.nix`) |

## Files

| File | Contents |
|---|---|
| `default.nix` | options, assertion, dispatcher |
| `<prompt>.nix` | config + one `shell.prompt.inits` entry |
| `../zsh/prompts/p10k-config.zsh` | trimmed `p10k configure` output; regenerate outside the store, re-trim by hand |

Adding a prompt: one `<name>.nix` registering `shell.prompt.inits.<name>`, gated on its program's `enable` if it has one, plus an `imports` entry.

## Git performance

| Setting | Location |
|---|---|
| `core.fsmonitor`, `core.untrackedCache` | git module |
| `command_timeout = 2000`, `git_status.ignore_submodules`, `git_metrics.disabled` | `starship.nix` |
| `POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY = -1` | p10k config |

Starship past `command_timeout` drops git segments silently. Network mounts: `git config core.fsmonitor false`.

## Inspecting a build

```bash
HM=$(nix build .#darwinConfigurations.default.config.home-manager.users.ahiggins.home.activationPackage --no-link --print-out-paths)
mkdir -p /tmp/zdot && cp "$(readlink -f "$HM/home-files/.zshrc")" "$(readlink -f "$HM/home-files/.zshenv")" /tmp/zdot/
ZDOTDIR=/tmp/zdot ZSH_PROMPT=starship script -q /dev/null zsh -i
```
