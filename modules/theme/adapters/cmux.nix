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

  chrome = pkgs.writeText "cmux-chrome.json" (
    builtins.toJSON {
      app.appearance = t.polarity;
      browser.theme = t.polarity;

      paneBorderColor = p.base01;
      activePaneBorderColor = p.base0C;

      sidebarAppearance.matchTerminalBackground = true;

      notifications.paneFlashColor = p.base0C;
      workspaceColors = {
        selectionColor = p.base02;
        notificationBadgeColor = p.base08;
      };
    }
  );

  applyChrome = pkgs.writeShellApplication {
    name = "cmux-apply-chrome";
    runtimeInputs = [
      pkgs.jq
      pkgs.gnused
    ];
    text = builtins.readFile ../../../scripts/cmux-apply-chrome.sh;
  };
in
{
  imports = [ ../../programs/cmux.nix ];

  config = lib.mkIf (ah.enabled config "cmux") {
    home.activation.cmuxThemeChrome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${applyChrome}/bin/cmux-apply-chrome ${chrome}
    '';
  };
}
