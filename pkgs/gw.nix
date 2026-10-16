# runs the nearest gradlew up the tree
{ writeShellApplication }:

writeShellApplication {
  name = "gw";
  text = ''
    dir=$(pwd)
    while [[ "$dir" != "/" ]]; do
      if [[ -f "$dir/gradlew" ]]; then
        (cd "$dir" && "$dir/gradlew" "$@")
        exit
      fi
      dir=$(dirname "$dir")
    done
    echo "gradlew not found in any parent of $dir" >&2
    exit 1
  '';
}
