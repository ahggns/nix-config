{ config, lib, ... }:

{
  config = lib.mkIf config.programs.awscli.enable {
    programs.awscli.settings.default = {
      region = lib.mkDefault "us-east-1";
      output = lib.mkDefault "json";
    };
  };
}
