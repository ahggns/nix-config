# neovim

Active when `programs.neovim.enable`. Colorscheme comes from the theme module.

| File | Contents |
|---|---|
| `default.nix` | `plugins`, `extraPackages` (LSPs, formatters), treesitter grammars |
| `init.lua` | all config: LSP, completion, telescope, conform, gitsigns, which-key, Claude Code, workspace layout |
| `config.vim` | indent, `termguicolors` |
| `vim-plist.nix` | unpackaged plugin (`buildVimPlugin` template) |

## Languages

| Language | Server | Formatter |
|---|---|---|
| Python | basedpyright, ruff | ruff_format |
| TS / JS / TSX | ts_ls | prettier |
| Java | jdtls | — |
| Nix | nil_ls | nixfmt |
| Bash / Zsh | bashls (`zsh` added to filetypes) | shfmt |
| Terraform | terraformls | terraform_fmt |
| Markdown | marksman | prettier |
| JSON / CSS / HTML | jsonls, cssls, html, tailwindcss | prettier |

Format on save is on for every filetype above.

## Keymaps (`<leader>` = space)

| Keys | Action |
|---|---|
| `ff` `fg` `fb` `fr` | files, grep, buffers, recent |
| `fs` `fd` | document symbols, diagnostics |
| `gd` `gD` `gr` `gi` `K` | definition, declaration, references, implementation, hover |
| `rn` `ca` | rename, code action |
| `e` `[d` `]d` | line diagnostics, prev/next |
| `cf` | format |
| `ac` `af` `ab` `as` | Claude: toggle, focus, add buffer, send selection |
| `aa` `ad` | Claude: accept/deny diff |
| `ww` / `:Workspace` | Claude split + terminal below editor; auto on `nvim` / `nvim <dir>` |

Leave a terminal window with `<C-\><C-n>`; `Esc` goes to the process (cancels Claude).

## Extending

| Add | Where |
|---|---|
| plugin | `plugins` + `require(...).setup()` in `init.lua` |
| language server | binary in `extraPackages`, name in `vim.lsp.enable({...})` (must exist in nvim-lspconfig `lsp/`) |
| grammar | `nvim-treesitter.withPlugins` list |
| formatter | `formatters_by_ft` + binary in `extraPackages` |
| keymap | `vim.keymap.set(..., { desc = ... })`; which-key reads `desc` |
| unpackaged plugin | copy `vim-plist.nix` |

APIs in use: `vim.lsp.config`/`vim.lsp.enable` (0.11+), nvim-treesitter main branch (`vim.treesitter.start`, no `configs` module).

## Inspecting a build

```bash
HM=$(nix build .#darwinConfigurations.default.config.home-manager.users.ahiggins.home.activationPackage --no-link --print-out-paths)
XDG_CONFIG_HOME="$HM/home-files/.config" XDG_DATA_HOME="$HM/home-files/.local/share" nvim
```
