# shellcheck shell=bash
# usage: cmux-apply-chrome CHROME_JSON
# cmux edits cmux.json itself: merge theme keys, never own the file
CONFIG="$HOME/.config/cmux/cmux.json"
CHROME="$1"

mkdir -p "$(dirname "$CONFIG")"
[ -f "$CONFIG" ] || echo '{}' >"$CONFIG"

# JSONC comments break jq; skip rather than strip them
if ! current=$(jq . "$CONFIG" 2>/dev/null); then
  echo "cmux.json has comments or is malformed; skipping" >&2
  exit 0
fi

merged=$(jq --slurpfile chrome "$CHROME" '. * $chrome[0]' <<<"$current")

# unchanged content must not touch mtime (cmux watches the file)
if [ "$(jq -S . <<<"$current")" != "$(jq -S . <<<"$merged")" ]; then
  echo "Applying theme chrome to cmux.json"
  printf '%s\n' "$merged" >"$CONFIG.tmp"
  mv "$CONFIG.tmp" "$CONFIG"
fi
