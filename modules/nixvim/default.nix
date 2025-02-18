{ pkgs, nixvim, ... }: {
  enable = true;

  enableMan = true;
  diagnostics.virtual_lines.only_current_line = true;

  autoGroups = { bun = { clear = true; }; };
  autoCmd = [{
    event = [ "BufWritePre" ];
    group = "bun";
    callback.__raw = ''
      function(args)
          local path = string.gsub(args.file, '(.*/)(.*)', '%1')
          if path == args.file then
              return
          end
          if not vim.loop.fs_stat(path) then
              vim.fn.system({ 'mkdir', '-p', path })
          end
      end
    '';
  }];

  colorschemes.kanagawa.enable = true;

  # let
  #     mkNeovimPlugin = nixvim.lib.nixvim.plugins.mkNeovimPlugin;
  #     minuet-ai = mkNeovimPlugin {
  #       name = "minuet-ai";
  #       maintainers = [ pkgs.lib.maintainers.fredeb ];
  #     };
  #   in
  plugins = let
    ginko = pkgs.rustPlatform.buildRustPackage rec {
      pname = "ginko";
      version = "0.0.8";

      src = pkgs.fetchFromGitHub {
        owner = "Schottkyc137";
        repo = "ginko";
        rev = "v${version}";
        hash = "sha256-lk+iZclni6jAkvN5/62YobFBAdwTUOfd5v7Fs8M6MQo=";
      };
      useFetchCargoVendor = true;
      cargoHash = "sha256-7VwvFDjwUZechUrkxnXPFN6aMkr9KJkV81rpOZJHr8E=";
    };
  in    
  {
    blink-cmp = {
      enable = true;   
      settings = {
        completion = {
          accept = {
            auto_brackets = {
              enabled = true;
              semantic_token_resolution.enabled = true;
            };
          };
          documentation.auto_show = true;
          list.selection = {
            preselect.__raw = "function(ctx) return ctx.mode ~= 'cmdline' end";
            auto_insert = false;
          };
        };
        keymap = {
          "<C-space>" = [ "show" "show_documentation" "hide_documentation" ];
          "<CR>" = [ "accept" "fallback" ];
        };
      };
    };
    cmake-tools.enable = true;
    codecompanion = {
      enable = true;
      settings = {
        strategies = {
          chat.adapter = "ollama";
          inline = {
            adapter = "ollama";
            keymaps = {
              accept_changes = {
                modes = { n = "ga"; };
              };
              reject_changes = {
                modes = { n = "gr"; };
              };
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
                      default = "deepseek-r1:14b"
                    }
                  }
                })
              end
          '';
          };
        };
      };
    };
    comment.enable = true;
    dap.enable = true;
    diffview.enable = true;
    friendly-snippets.enable = true;
    fzf-lua = {
      enable = true;
      settings = {
        fzf_bin = "fzf-tmux";
        winopts.preview.default = "bat";
      };
    };
    git-conflict.enable = true;
    gitsigns.enable = true;
    lualine.enable = true;
    neogit = {
      enable = true;
      settings = {
        use_magit_keybinds = true;
        kind = "split";
        auto_show_console = false;
        disable_builtin_notifications = true;
        disable_commit_confirmation = true;
        integrations = {
          diffview = true;
        };
      };
    };
    neotest = {
      enable = true;
      adapters = {
        # TODO: ctest
        bash.enable = true;
        python.enable = true;
      };
    };
    lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        clangd = {
          enable = true;
          cmd = [
            "clangd"
            "--header-insertion=never"
            "--all-scopes-completion"
            "--background-index"
            "--clang-tidy"
            "--compile-commands-dir=build"
            "--query-driver=/**/*"
          ];
        };
        docker_compose_language_service.enable = true;
        dockerls.enable = true;
        gopls.enable = true;
        ginko_ls = {
          enable = true;
          package = ginko;
        };
        lua_ls.enable = true;
        neocmake.enable = true;
        nixd.enable = true;
        pyright.enable = true;
        ruff.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
        terraformls.enable = true;
        ts_ls.enable = true;
        verible.enable = true;
        zls.enable = true;
      };
    };
    nvim-bqf.enable = true;
    notify.enable = true;
    ollama = {
      enable = true;

    };
    oil.enable = true;
    persisted.enable = true;
    tmux-navigator.enable = true;
    treesitter.enable = true;
    web-devicons.enable = false;
  };

  globals = {
    mapleader = " ";
    foldenable = false;
  };

  opts = {
    completeopt = "menuone,noinsert,noselect";
    expandtab = true;
    hidden = true;
    ignorecase = true;
    number = true;
    scrolloff = 15;
    shiftwidth = 4;
    smartcase = true;
    tabstop = 4;
    wildmode = "longest,list";
    laststatus = 3;
    inccommand = "nosplit";
    termguicolors = true;
    fixeol = false;
    signcolumn = "yes:1";
    guifont = "Iosevka Nerd Font:h10";
    mousemodel = "extend";
    cmdheight = 0;
    foldenable = false;
    jumpoptions = "stack";
    scrollback = 100000;
    undofile = true;
  };

  keymaps = [
    # dap
    { mode = "n"; key = "<F2>"; action.__raw = ''require('dap').step_over''; }
    { mode = "n"; key = "<F3>"; action.__raw = ''require('dap').step_into''; }
    { mode = "n"; key = "<F4>"; action.__raw = ''require('dap').step_out''; }
    { mode = "n"; key = "<F5>"; action.__raw = ''require('dap').continue''; }
    { mode = "n"; key = "<F6>"; action.__raw = ''require('dap').run_to_cursor''; }
    { mode = "n"; key = "<F3>"; action.__raw = ''require('dap').toggle_breakpoint''; }
    
    # fzf
    { mode = "n"; key = "<leader><leader>"; action.__raw = ''require('fzf-lua').resume''; }
    { mode = "n"; key = "<leader>gl"; action.__raw = ''require('fzf-lua').git_commits''; }
    { mode = "n"; key = "<leader>gf"; action.__raw = ''require('fzf-lua').git_bcommits''; }
    { mode = "n"; key = "<leader>ff"; action.__raw = ''require('fzf-lua').files''; }
    { mode = "n"; key = "<leader>fg"; action.__raw = ''require('fzf-lua').live_grep''; }
    { mode = "n"; key = "<leader>fr"; action.__raw = ''require('fzf-lua').grep_cword''; }
    { mode = "v"; key = "<leader>fr"; action.__raw = ''require('fzf-lua').grep_visual''; }
    { mode = "n"; key = "<leader>;"; action.__raw = ''require('fzf-lua').commands''; }
    { mode = "n"; key = "<leader>b"; action.__raw = ''require('fzf-lua').buffers''; }
    { mode = "n"; key = "<leader>l"; action.__raw = ''require('fzf-lua').lines''; }
    { mode = "n"; key = "<leader>gb"; action.__raw = ''require('fzf-lua').git_branches''; }
    { mode = "n"; key = "<leader>h"; action.__raw = ''require('fzf-lua').help_tags''; }

    # git
    { mode = "n"; key = "<leader>gq"; action.__raw = ''require("gitsigns").setqflist''; }
    { mode = "n"; key = "<leader>gA"; action.__raw = ''require("gitsigns").stage_buffer''; }
    { mode = "n"; key = "<leader>gR"; action.__raw = ''require("gitsigns").reset_buffer''; }
    { mode = [ "n" "v" ]; key = "<leader>ga"; action.__raw = ''require("gitsigns").stage_hunk''; }
    { mode = [ "n" "v" ]; key = "<leader>gr"; action.__raw = ''require("gitsigns").reset_hunk''; }
    { mode = "n"; key = "<leader>gu"; action.__raw = ''require("gitsigns").undo_stage_hunk''; }
    { mode = "n"; key = "<leader>gp"; action.__raw = ''require("gitsigns").preview_hunk''; }
    { mode = "n"; key = "<leader>gm"; action.__raw = ''function() require("gitsigns").blame_line({ full = true }) end''; }
    { mode = "n"; key = "<leader>gs"; action.__raw = ''require("neogit").open''; }

    # lsp
    { mode = "n"; key = "gD"; action.__raw = ''vim.lsp.buf.declaration''; }
    { mode = "n"; key = "gd"; action.__raw = ''vim.lsp.buf.definition''; }
    { mode = [ "n" "i" ]; key = "<C-s>"; action.__raw = ''vim.lsp.buf.signature_help''; }
    { mode = [ "n" "i" ]; key = "<C-t>"; action.__raw = ''vim.lsp.buf.hover, { buffer = 0, noremap = true, silent = true }''; }
    { mode = "n"; key = "<leader>rr"; action.__raw = ''vim.lsp.buf.references''; }
    { mode = "n"; key = "<leader>ro"; action.__raw = ''vim.lsp.buf.rename''; }
    { mode = "n"; key = "<leader>re"; action.__raw = ''vim.lsp.buf.code_action''; }
    { mode = "n"; key = "<leader>rn"; action.__raw = ''vim.diagnostic.goto_next''; }
    { mode = "n"; key = "<leader>rp"; action.__raw = ''vim.diagnostic.goto_prev''; }
    { mode = "n"; key = "<leader>rd"; action.__raw = ''vim.diagnostic.setqflist''; }
    { mode = [ "n" "v" ]; key = "<leader>rf"; action.__raw = ''function() vim.lsp.buf.format({ async = true}) end''; }

    # buffers
    { mode = "n"; key = "<leader>q"; action = ''<cmd>bd<cr>''; }
    { mode = "n"; key = "<leader>Q"; action = ''<cmd>q!<cr>''; }

    # quickfix
    { mode = "n"; key = "<C-p>"; action = ''<cmd>cprev<cr>zz''; }
    { mode = "n"; key = "<C-n>"; action =''<cmd>cnext<cr>zz''; }
    { mode = "n"; key = "<C-q>"; action = ''<cmd>copen<cr>''; }
    { mode = "n"; key = "<C-c>"; action = ''<cmd>cclose<cr>''; }

    { mode = "n"; key = "<leader>as"; action.__raw = ''require('persisted').load''; }
  ];
}
