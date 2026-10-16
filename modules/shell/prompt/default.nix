{ lib, config, ... }:

let
  ah = import ../../lib.nix { inherit lib; };
  cfg = config.shell.prompt;

  indent =
    prefix: text:
    lib.concatMapStringsSep "\n" (line: if line == "" then "" else prefix + line) (
      lib.splitString "\n" (lib.removeSuffix "\n" text)
    );

  branch = name: init: "  ${name})\n${indent "    " init}\n    ;;";
in
{
  imports = [
    ./p10k.nix
    ./starship.nix
    ./oh-my-posh.nix
    ./pure.nix
  ];

  options.shell.prompt = {
    default = lib.mkOption {
      type = lib.types.str;
      default = "p10k";
      example = "starship";
      description = "Prompt for new shells; ZSH_PROMPT=<name> overrides per shell.";
    };

    inits = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      internal = true;
      default = { };
      description = "Prompt name -> zsh snippet that activates it.";
    };
  };

  config = lib.mkIf (ah.enabled config "zsh") {
    assertions = [
      {
        assertion = cfg.inits ? ${cfg.default};
        message =
          "shell.prompt.default = \"${cfg.default}\" is not a known prompt. "
          + "Available: ${lib.concatStringsSep ", " (lib.attrNames cfg.inits)}.";
      }
    ];

    programs.zsh.initContent = lib.mkAfter ''
      # Prompt dispatch: ZSH_PROMPT=<name> overrides for one shell
      case "''${ZSH_PROMPT:-${cfg.default}}" in
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList branch cfg.inits)}
        *)
          print -u2 "ZSH_PROMPT=''${ZSH_PROMPT}: unknown prompt (known: ${lib.concatStringsSep " " (lib.attrNames cfg.inits)})"
          ;;
      esac
    '';
  };
}
