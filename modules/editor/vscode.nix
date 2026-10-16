{ config, lib, ... }:

let
  ah = import ../lib.nix { inherit lib; };

  font = config.terminal.font.name or null;
  fontFamily = "${font}, Menlo, Monaco, 'Courier New', monospace";

  adapt = app: {
    programs.${app}.profiles.default.userSettings = ah.defaults (
      {
        "github.copilot.enable" = {
          "*" = true;
          "plaintext" = true;
          "markdown" = false;
          "scminput" = false;
        };
        "python.languageServer" = "Pylance";
        "python.testing.pytestEnabled" = true;
        "python.analysis.typeCheckingMode" = "standard";
        "jupyter.askForKernelRestart" = false;
      }
      // lib.optionalAttrs (font != null) {
        "editor.fontFamily" = fontFamily;
        "terminal.integrated.fontFamily" = fontFamily;
      }
    );
  };
in
{
  config = lib.mkMerge (
    map (app: lib.mkIf (ah.enabled config app) (adapt app)) [
      "vscode"
      "cursor"
    ]
  );
}
