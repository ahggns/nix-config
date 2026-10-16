# programs.cmux shim (none in home-manager)
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.cmux;
in
{
  options.programs.cmux = {
    enable = lib.mkEnableOption "cmux";
    package = lib.mkPackageOption pkgs "cmux" { nullable = true; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) cfg.package;
  };
}
