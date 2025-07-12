{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption types;
in {
  options.git-tools = {
    enable = mkEnableOption "Git tools";

    enable-bash-aliases = mkOption {
      default = true;
      type = types.bool;
    };

    enable-git-aliases = mkOption {
      default = true;
      type = types.bool;
    };
  };
  config = let cfg = config.git-tools; in mkIf cfg.enable {
    home.packages = [ (pkgs.callPackage ../packages/git-tools/git-tools.nix {}) ];
    programs.git.extraConfig.alias = mkIf cfg.enable-git-aliases {
      fzf-log = "!git-fzf-log.sh";
      fzf-worktree = "!git-fzf-worktree.sh";
      list-stashes = "!git-list-stashes.sh";
      list-branches = "!git-list-branches.sh";
      list-reflog = "!git-back.sh";
    };
    programs.bash.shellAliases = mkIf cfg.enable-bash-aliases {
      gs = "git status";
      gd = "git diff";
      gl = "git-fzf-log.sh";     
      gw = "git-fzf-worktree.sh";     
      gst = "git-list-stashes.sh";     
      gbr = "git-list-branches.sh";     
      gba = "git-back.sh";     
    };
  };
}
