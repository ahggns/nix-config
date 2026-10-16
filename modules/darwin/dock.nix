{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.dock;

  # dockutil lists directories with a trailing slash
  normalize = path: path + "/";

  entryURI =
    path:
    "file://"
    + (builtins.replaceStrings
      [
        " "
        "!"
        "\""
        "#"
        "$"
        "%"
        "&"
        "'"
        "("
        ")"
      ]
      [
        "%20"
        "%21"
        "%22"
        "%23"
        "%24"
        "%25"
        "%26"
        "%27"
        "%28"
        "%29"
      ]
      (normalize path)
    );

  wantURIs = lib.concatMapStrings (entry: "${entryURI entry.path}\n") cfg.entries;

  createEntries = lib.concatMapStrings (
    entry:
    "${pkgs.dockutil}/bin/dockutil --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}\n"
  ) cfg.entries;
in
{
  options.dock = {
    enable = lib.mkEnableOption "declarative Dock management via dockutil";

    username = lib.mkOption {
      type = lib.types.str;
      default = config.system.primaryUser;
      defaultText = lib.literalExpression "config.system.primaryUser";
      description = "User whose Dock is managed.";
    };

    entries = lib.mkOption {
      description = "Persistent Dock entries, applied in this order.";
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption { type = lib.types.str; };
            section = lib.mkOption {
              type = lib.types.str;
              default = "apps";
              description = ''"apps" or "others" (dockutil's own sections).'';
            };
            options = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Extra dockutil flags for this entry, e.g. --view grid.";
            };
          };
        }
      );
    };
  };

  # diffs the live Dock first; resets only on mismatch
  config = lib.mkIf cfg.enable {
    system.activationScripts.postActivation.text = ''
      echo >&2 "Checking Dock entries for ${cfg.username}..."
      sudo -u ${cfg.username} ${pkgs.zsh}/bin/zsh -s /bin/sh <<'USERBLOCK'
      haveURIs="$(${pkgs.dockutil}/bin/dockutil --list | ${pkgs.gawk}/bin/awk -F'\t' '$3 == "persistentApps" || $3 == "persistentOthers" {print $2}')"
      if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
        echo >&2 "Resetting Dock."
        ${pkgs.dockutil}/bin/dockutil --no-restart --remove all
        ${createEntries}
        killall Dock
      else
        echo >&2 "Dock entries already match."
      fi
      USERBLOCK
    '';
  };
}
