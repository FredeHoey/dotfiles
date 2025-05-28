{ config, lib, pkgs, nixvim, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption types;
  cfg = config.ai;
in {
  options.ai = {
    enable = mkEnableOption "AI Module";

    ollama = {
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

    programs.nixvim.plugins.codecompanion = {
      enable = true;
      settings = {
        strategies = {
          chat.adapter = "ollama";
          inline = {
            adapter = "ollama";
            keymaps = {
              accept_changes = { modes = { n = "ga"; }; };
              reject_changes = { modes = { n = "gr"; }; };
            };
          };
        };
        adapters = {
          ollama = {
            __raw = ''
              function()
                return require("codecompanion.adapters").extend("ollama", {
                  schema = {
                    model = {
                      default = "${cfg.ollama.code-model}"
                    }
                  }
                })
              end
            '';
          };
        };
      };
    };
    programs.git.extraConfig.alias = {
      explain = ''
        !f() { 
            ollama run ${cfg.ollama.chat-model} "Explain what the purpose of this changeset is:

            $(git show -b $*)
        "; };
        f | ${pkgs.glow}/bin/glow -p -'';
      review = ''
        !f() { 
            ollama run ${cfg.ollama.chat-model} "$(cat .context 2> /dev/null)
            Review this changeset. Provide suggestions for improvements, coding best practices, improve readability, and maintainability.

            $(git show -b $*)

            $diff
            
        "; }; f | ${pkgs.glow}/bin/glow -p -'';
      pre-review = ''
        !f() { 
            diff=$(git diff --no-ext-diff -W --staged)
            if [[ $? -ne 0 ]]; then
              echo No files in staging area
              exit 1
            fi

            ollama run ${cfg.ollama.chat-model} "$(cat .context 2> /dev/null)
            Review this changeset as a senior engineer with expertise in the field would. If the change set is empty, respond only with "No changes staged".

            $diff
        "; }; f | ${pkgs.glow}/bin/glow -p -'';
      vibe-commit = ''
        !f() {
            diff=$(git diff --no-ext-diff --staged)
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
