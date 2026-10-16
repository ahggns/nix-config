{ config, lib, ... }:

let
  ah = import ../lib.nix { inherit lib; };
in
{
  config = lib.mkIf (ah.enabled config "git") {
    programs.git = {
      lfs.enable = lib.mkDefault true;

      settings = ah.defaults {
        init.defaultBranch = "main";

        # fast `git status` for daemonless prompts; disable per-repo on network mounts
        core = {
          fsmonitor = true;
          untrackedCache = true;
        };

        alias = {
          l = "log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all";
          ld = "l --simplify-by-decoration";
          b = "for-each-ref --sort=-committerdate --color=always --format='%(color:green)%(committerdate:short)%(color:reset) %(color:red)%(objectname:short)%(color:reset) %(color:blue)%(refname:short)%(color:reset) - %(color:yellow)<%(authorname)>%(color:reset) %(color:white)%(contents:subject)%(color:reset) %(color:green)(%(committerdate:relative))%(color:reset)' refs/heads/";
          d = ''!f() { current=$(git rev-parse --abbrev-ref HEAD); main=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || git branch -r | grep -E 'origin/(main|master)' | head -1 | sed 's@^[[:space:]]*origin/@@'); target=''${1:-$current}; base=$(git merge-base "$main" "$target" 2>/dev/null); if [ -n "$base" ]; then git diff "$base" "$target"; else echo "No common ancestor found between $main and $target"; fi; }; f'';
          u = "shortlog -s -n --no-merges --";
          cleanup = "!git checkout $(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5) && git pull && git prune && git remote prune origin && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D";
        };
      };
    };
  };
}
