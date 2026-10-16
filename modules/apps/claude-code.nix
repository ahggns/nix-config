# claude is a self-updating install outside nix; the function wraps whichever is on PATH
{
  config,
  lib,
  pkgs,
  ...
}:

let
  sessionOverrides = (pkgs.formats.json { }).generate "claude-session-overrides.json" {
    editorMode = "vim";
    # only ansi themes follow the terminal palette
    theme = "dark-ansi";
  };
in
{
  config = lib.mkIf config.programs.zsh.enable {
    programs.zsh.initContent = ''
      claude() {
        command claude --settings '${sessionOverrides}' "$@"
      }
    '';
  };
}
