{ config, lib, pkgs, ... }:
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
        default = "gpt-oss:20b";
      };
      code-model = mkOption {
        type = types.str;
        default = "qwen3-coder:30b";
      };
      editor-model = mkOption {
        type = types.str;
        default = "qwen3:14b";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.nixvim.plugins.codecompanion = {
      enable = true;
      settings = {
        strategies = {
          chat.adapter = "chat";
          inline.adapter = "inline";
          cmd.adapter = "cmd";
        };
        adapters = {
          chat.__raw = ''
              function()
                return require("codecompanion.adapters").extend("ollama", {
                  name = "chat",
                  schema = {
                    model = {
                      default = "${cfg.ollama.chat-model}"
                    },
                    num_ctx = {
                      default = 16384,
                    },
                    num_predict = {
                      default = -1,
                    }
                  }
                })
              end
            '';
          inline .__raw = ''
              function()
                return require("codecompanion.adapters").extend("ollama", {
                  name = "inline",
                  schema = {
                    model = {
                      default = "${cfg.ollama.code-model}"
                    },
                    num_ctx = {
                      default = 16384,
                    },
                    num_predict = {
                      default = -1,
                    }
                  }
                })
              end
            '';
          editor.__raw = ''
              function()
                return require("codecompanion.adapters").extend("ollama", {
                  name = "editor",
                  schema = {
                    model = {
                      default = "${cfg.ollama.editor-model}"
                    },
                    num_ctx = {
                      default = 16384,
                    },
                    num_predict = {
                      default = -1,
                    }
                  }
                })
              end
            '';
          };
        };
      };
    programs.git.extraConfig.alias = let
      ollama_cmd = "OLLAMA_CONTEXT_LENGTH=131072 ollama run $(ollama list | tail -n +2 | fzf | sed -E 's/\s.*//')";
    in {
      explain = ''
        !f() { 
            ${ollama_cmd} "Explain what the purpose of this changeset is:

            $(git show -m -b -U40 $*)
        "; };
        f'';
      review = ''
        !f() { 
            ${ollama_cmd} "$(cat .context 2> /dev/null)
            Review this changeset. Provide suggestions for improvements, coding best practices, improve readability, and maintainability.

            $(git show -m -b -U40 $*)

            $diff
            
        "; }; f'';
      pre-review = ''
        !f() { 
            diff=$(git diff --no-ext-diff -W --staged)
            if [[ $? -ne 0 ]]; then
              echo No files in staging area
              exit 1
            fi

            ${ollama_cmd} "$(cat .context 2> /dev/null)
            Review this changeset as a senior engineer with expertise in the field would. Focus on the added lines, prefixed with a '+' and the removed lines, prefixed with a '-', every other line is simply context. If the change set is empty, respond only with "No changes staged".

            $diff
        "; }; f'';
      vibe-commit = ''
        !f() {
            diff=$(git diff --no-ext-diff --staged)
            if [[ $? -ne 0 ]]; then
              echo No files in staging area
              exit 1
            fi

            ${ollama_cmd} "$(cat .context 2> /dev/null)
            Please write a commit message for the following patch following the convetional commits v1.0.0 specification.
            Don't include any explanation in the output, only the commit text as it would be written in a git commit
            
            Patch:
            $diff
        "; }; git commit -m "$(f)" -e'';
    };
  };
}
