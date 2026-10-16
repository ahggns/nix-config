{ lib, config, ... }:

let
  ah = import ../../lib.nix { inherit lib; };
in
{
  config = lib.mkIf (ah.enabled config "zsh" && ah.enabled config "starship") {
    programs.starship = {
      # dispatcher owns activation
      enableZshIntegration = lib.mkDefault false;

      settings = ah.defaults {
        add_newline = false;

        command_timeout = 2000;
        scan_timeout = 50;

        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
          style = "bold blue";
        };

        git_branch.style = "bold bright-magenta";

        git_status = {
          style = "bold yellow";
          ignore_submodules = true;
        };

        git_metrics.disabled = true;

        cmd_duration = {
          min_time = 3000;
          style = "bold yellow";
        };
      };
    };

    shell.prompt.inits.starship = ''
      eval "$(${lib.getExe config.programs.starship.package} init zsh)"
    '';
  };
}
