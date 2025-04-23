{ config, lib, pkgs, nixvim, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption types;
  cfg = config.ai;
in {
  options.ai = {
    enable = mkEnableOption "AI Module";

    ollama = rec {
      host = mkOption {
        type = types.str;
        default = "localhost";
      };
      port = mkOption {
        type = types.int;
        default = 11434;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.ollama;
      };
      chat-model = mkOption {
        type = types.str;
        default = "gemma3:12b";
      };
      code-model = mkOption {
        type = types.str;
        default = "deepcoder:14b";
      };
    };
  };
  config = mkIf cfg.enable {
    services.ollama = mkIf (cfg.ollama.host == "localhost") {
      enable = true;
      port = cfg.ollama.port;
    };

    programs.nixvim.plugins.avante = {
      enable = cfg.enable;
      package = pkgs.vimPlugins.avante-nvim.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "yetone";
          repo = "avante.nvim";
          rev = "06757e8bf57175da45180a26840c5db1f38cb4d9";
          hash = "sha256-8q3xF9SiM/uJzHVaynn71p4yftMw5ZkiquzXXcOeSf0=";
        };
        doCheck = false;
      };
      settings = {
        ollama = {
          model = cfg.ollama.code-model;
          endpoint = "http://${cfg.ollama.host}:${builtins.toString cfg.ollama.port}";
        };
        provider = "ollama";
      };
    };
    programs.git.extraConfig.aliases = {
          explain = ''
            !f() { 
                ollama run ${cfg.ollama.chat-model} "Explain what the purpose of this changeset is:

                $(git show -b $*)
            "; };
            f'';
          review = ''
            !f() { 
                ollama run ${cfg.ollama.chat-model} "$(cat .context 2> /dev/null)
                Review this changeset. Provide suggestions for improvements, coding best practices, improve readability, and maintainability.

                $(git show -b $*)

                $diff
                
            "; }; f'';
          pre-review = ''
            !f() { 
                diff=$(git diff --staged)
                if [[ $? -ne 0 ]]; then
                  echo No files in staging area
                  exit 1
                fi

                ollama run ${cfg.ollama.chat-model} "$(cat .context 2> /dev/null)
                Review this changeset. Provide suggestions for improvements, coding best practices, improve readability, and maintainability.

                $diff
            "; }; f'';
          vibe-commit = ''
            !f() {
                diff=$(git diff --staged)
                if [[ $? -ne 0 ]]; then
                  echo No files in staging area
                  exit 1
                fi

                ollama run ${cfg.ollama.chat-model} "$(cat .context 2> /dev/null)
                Please write a commit message for the following patch following the convetional commits v1.0.0 specification.
                Don't include any explanation in the output, only the commit text as it would be written in a git commit
                
                Patch:
                $diff
            "; }; git commit -m "$(f)" -e'';
        };
  };
}
