# shellcheck shell=bash
# usage: switch MACHINE_OUT_PATH
# built as the invoking user (ssh for private inputs); root only sets the profile and activates
out="$1"
if [ "$(uname)" = Darwin ]; then
  sudo "$(command -v nix-env)" -p /nix/var/nix/profiles/system --set "$out"
  sudo "$out/activate"
else
  "$out/activate"
fi
