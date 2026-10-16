# ctrl+l used for tmux (switch pane)
for km in viins vicmd; do
  bindkey -M $km -r '^l'
  bindkey -M $km -r '^g'
  bindkey -M $km '^g' .clear-screen

  bindkey -M $km -r '^p'
  bindkey -M $km -s '^p' 'fpdf\n'
done

# edit current command line with vim (vim-mode, then CTRL-v)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^v' edit-command-line

# inside nvim's terminal, vicmd space hands off to nvim: leaves terminal mode
# and leaves <leader> pending, so the keys after it hit nvim's maps, not zle's.
# the leader must go in on a later loop iteration (vim.schedule) than the mode
# switch -- fed in the same batch, zle's redraw flushes it before it can pend.
if [[ -n $NVIM ]] && (( $+commands[nvim] )); then
  nvim-leader() {
    nvim --server "$NVIM" --remote-send \
      '<C-\><C-n><Cmd>lua vim.schedule(function() vim.api.nvim_input(" ") end)<CR>' &>/dev/null
  }
  zle -N nvim-leader
  bindkey -M vicmd ' ' nvim-leader
fi

# +---------------------------------+
# | Simply mapping escape sequences |
# +---------------------------------+

for km in viins vicmd; do
  bindkey -M $km -s '^[OM'    '^M'
  bindkey -M $km -s '^[Ok'    '+'
  bindkey -M $km -s '^[Om'    '-'
  bindkey -M $km -s '^[Oj'    '*'
  bindkey -M $km -s '^[Oo'    '/'
  bindkey -M $km -s '^[OX'    '='
  bindkey -M $km -s '^[OA'    '^[[A'
  bindkey -M $km -s '^[OB'    '^[[B'
  bindkey -M $km -s '^[OD'    '^[[D'
  bindkey -M $km -s '^[OC'    '^[[C'
  bindkey -M $km -s '^[OH'    '^[[H'
  bindkey -M $km -s '^[[1~'   '^[[H'
  bindkey -M $km -s '^[[7~'   '^[[H'
  bindkey -M $km -s '^[OF'    '^[[F'
  bindkey -M $km -s '^[[4~'   '^[[F'
  bindkey -M $km -s '^[[8~'   '^[[F'
  bindkey -M $km -s '^[[3\^'  '^[[3;5~'
  bindkey -M $km -s '^[^[[3~' '^[[3;3~'
  bindkey -M $km -s '^[[1;9C' '^[[1;3C'
  bindkey -M $km -s '^[^[[C'  '^[[1;3C'
  bindkey -M $km -s '^[[1;9D' '^[[1;3D'
  bindkey -M $km -s '^[^[[D'  '^[[1;3D'
  bindkey -M $km -s '^[Od'    '^[[1;5D'
  bindkey -M $km -s '^[Oc'    '^[[1;5C'
done
