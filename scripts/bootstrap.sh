#!/usr/bin/env bash
# First switch (nix-darwin, then home-manager) of the flake in $PWD (or $1). Idempotent.
# Prereqs: Xcode CLT; an ssh-agent key if the flake has private inputs.
set -euo pipefail

FLAKE_DIR="$(cd "${1:-$PWD}" && pwd)"

confirm() {
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

if [ "$EUID" -eq 0 ]; then
  echo "run as your user; sudo is used only where needed" >&2
  exit 1
fi

echo "== ssh"
# github exits 1 on -T even when auth succeeds
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" ||
  echo "warning: no github ssh auth; private flake inputs will fail" >&2

echo "== nix"
command -v nix >/dev/null 2>&1 || sh <(curl -L https://nixos.org/nix/install)
# shellcheck disable=SC1091
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] &&
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "== /etc shell rc files nix-darwin won't overwrite"
for f in /etc/zshrc /etc/bashrc; do
  if [ -e "$f" ] && ! grep -q "generated automatically" "$f" 2>/dev/null; then
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done

echo "== unmanaged homebrew taps"
TAPS_DIR="/opt/homebrew/Library/Taps"
if [ -d "$TAPS_DIR" ] && [ ! -L "$TAPS_DIR" ]; then
  find "$TAPS_DIR" -mindepth 2 -maxdepth 2 -type d
  echo "taps above not declared in the flake are dropped"
  if confirm "move $TAPS_DIR aside?"; then
    sudo mv "$TAPS_DIR" "$TAPS_DIR.before-nix-homebrew"
  else
    exit 1
  fi
fi

echo "== ~/.zshenv symlink home-manager can't back up"
if [ -L "$HOME/.zshenv" ] && [[ "$(readlink "$HOME/.zshenv")" != /nix/store/* ]]; then
  mv "$HOME/.zshenv" "$HOME/.zshenv.before-home-manager"
fi

echo "== switch"
nix --extra-experimental-features 'nix-command flakes' run "$FLAKE_DIR#system"
nix run "$FLAKE_DIR"

echo "done; open a new terminal"
