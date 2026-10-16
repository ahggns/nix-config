{ lib }:

{
  # leaf-wise mkDefault; lists and derivations are leaves
  defaults = lib.mapAttrsRecursiveCond (as: !lib.isDerivation as) (_: lib.mkDefault);

  importDir =
    dir:
    lib.mapAttrsToList (name: _: dir + "/${name}") (
      lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) (builtins.readDir dir)
    );

  enabled = config: name: config.programs.${name}.enable or false;
}
