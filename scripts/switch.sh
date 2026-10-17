# shellcheck shell=bash
# usage: switch OUT_PATH  (home-manager activationPackage or nix-darwin system)
# built as the invoking user (ssh for private inputs); root only sets the system profile and activates
out="$1"
if [ -e "$out/darwin-version" ]; then
  sudo -H "$(command -v nix-env)" -p /nix/var/nix/profiles/system --set "$out"
  sudo -H "$out/activate"
else
  "$out/activate"
fi
