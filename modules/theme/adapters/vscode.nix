{
  config,
  lib,
  pkgs,
  ...
}:

let
  ah = import ../../lib.nix { inherit lib; };
  t = (import ../lib.nix { inherit lib pkgs; }).resolve config.theme;
  p = t.palette;
  native = t.native.vscode or null;

  ansiNames = [
    "Black"
    "Red"
    "Green"
    "Yellow"
    "Blue"
    "Magenta"
    "Cyan"
    "White"
  ];
  ansiKeys = map (c: "terminal.ansi${c}") ansiNames ++ map (c: "terminal.ansiBright${c}") ansiNames;

  colorCustomizations = {
    "editor.background" = p.base00;
    "editor.foreground" = p.base05;
    "editor.selectionBackground" = p.base02;
    "editor.lineHighlightBackground" = p.base01;
    "editorCursor.foreground" = p.base05;
    "editorLineNumber.foreground" = p.base03;
    "editorLineNumber.activeForeground" = p.base04;
    "sideBar.background" = p.base01;
    "activityBar.background" = p.base01;
    "titleBar.activeBackground" = p.base00;
    "statusBar.background" = p.base01;
    "statusBar.foreground" = p.base04;
    "tab.activeBackground" = p.base00;
    "tab.inactiveBackground" = p.base01;
    "panel.background" = p.base00;
    "focusBorder" = p.base0C;
    "terminal.background" = p.base00;
    "terminal.foreground" = p.base05;
  }
  // lib.listToAttrs (lib.zipListsWith lib.nameValuePair ansiKeys t.ansi);

  adapt = app: {
    programs.${app}.profiles.default = {
      extensions = lib.optional (native != null) native.extension;
      userSettings = ah.defaults (
        if native != null then
          { "workbench.colorTheme" = native.colorTheme; }
        else
          {
            "workbench.colorTheme" =
              if t.polarity == "dark" then "Default Dark Modern" else "Default Light Modern";
            "workbench.colorCustomizations" = colorCustomizations;
          }
      );
    };
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
