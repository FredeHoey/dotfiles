{ pkgs, ... }: {
  config.programs.nixvim = {
  enable = true;

  enableMan = true;

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

  extraPlugins = [
    pkgs.vimPlugins.tardis-nvim
    (pkgs.vimUtils.buildVimPlugin {
      name = "kanagawa";
      src = pkgs.fetchFromGitHub {
        owner = "rebelot";
        repo = "kanagawa.nvim";
        rev = "debe91547d7fb1eef34ce26a5106f277fbfdd109";
        hash = "sha256-i54hTf4AEFTiJb+j5llC5+Xvepj43DiNJSq0vPZCIAg=";
      };
      doCheck = false;
    })
  ];
  colorschemes.kanagawa = {
    enable = true;
    autoLoad = true;
  };

  extraConfigLua = ''
    require("fzf-lua").register_ui_select()
  '';

  plugins = {
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
    clangd-extensions.enable = true;
    cmake-tools = {
      enable = true;
      settings = {
        cmake_notifications = {
          runner.enabled = false;
          executor.enabled = false;
        };
        cmake_runner = {
          opts = {
            terminal = {
              split_direction = "vertical";
              split_size = 30;
            };
          };
        };
        cmake_dap_configuration = {
          name = "cpp";
          type = "gdb";
          request = "launch";
          runInTerminal = true;
          console = "integratedTerminal";
          stopOnEntry = false;
        };
      };
    };
    comment.enable = true;
    dap = {
      enable = true;

      adapters = {
        pipes = {
          cmake = {
            pipe = "$\{pipe}";
            executable = {
                command = "cmake";
                args = [ "--debugger" "--debugger-pipe" "$\{pipe}" "build" ];
            };
          };
        };
        executables = {
          bash = {
            command = "bash-debug-adapter";
          }; 
          gdb = {
            command = "gdb";
            args = [ "--interpreter=dap" "--eval-command" "set print pretty on" ];
          };
          python = {
            command = "uvx";
            args = [ "--from" "debugpy" "debugpy-adapter" ];
          };
        };
      };
      luaConfig.post = ''
        local dap = require('dap')

        require('dap.ext.vscode').type_to_filetypes = {
            gdb = { 'c', 'cpp' },
        }
      '';
    };
    dap-view = {
      enable = true;
      settings = {
        auto_toggle = true;
      };
    };
    diffview.enable = true;
    friendly-snippets.enable = true;
    fzf-lua = {
      enable = true;
      settings = {
        winopts = {
          border = "none";
          preview = {
            border = "none";
            layout = "vertical";
          };
        };
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
      };
    };
    neogen.enable = true;
    neotest = {
      enable = true;
      adapters = {
        bash.enable = true;
        ctest = {
          enable = true;
          settings = {
            is_test_file.__raw = ''
              function(file_path)
                return string.match(file_path, "test") ~= nil
              end
            '';
            frameworks = [ "catch2" ];
          };
        };
        python.enable = true;
      };
    };
    lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        clangd = {
          package = null;
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
          package = pkgs.ginko;
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
        svelte.enable = true;
        terraformls.enable = true;
        ts_ls.enable = true;
        verible.enable = true;
        zls.enable = true;
      };
    };
    nvim-bqf.enable = true;
    notify = {
      enable = true;
      settings.background_colour = "#000000";
    };
    persisted.enable = true;
    tiny-inline-diagnostic.enable = true;
    tmux-navigator.enable = true;
    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        incremental_selection.enable = true;
        indent.enable = false;
      };
    };
    web-devicons.enable = false;
    yazi.enable = true;
  };

  globals = {
    mapleader = " ";
    foldenable = false;
  };

  opts = {
    cmdheight = 0;
    completeopt = "menuone,noinsert,noselect";
    expandtab = true;
    fixeol = false;
    foldenable = false;
    hidden = true;
    ignorecase = true;
    inccommand = "nosplit";
    jumpoptions = "stack";
    laststatus = 3;
    mousemodel = "extend";
    number = true;
    scrollback = 100000;
    scrolloff = 15;
    shiftwidth = 4;
    signcolumn = "yes:1";
    smartcase = true;
    tabstop = 4;
    termguicolors = true;
    undofile = true;
    wildmode = "longest,list";
  };

  keymaps = [
    # dap
    {
      mode = "n";
      key = "<leader>n";
      action.__raw = "require('dap').step_over";
    }
    {
      mode = "n";
      key = "<leader>i";
      action.__raw = "require('dap').step_into";
    }
    {
      mode = "n";
      key = "<leader>o";
      action.__raw = "require('dap').step_out";
    }
    {
      mode = "n";
      key = "<leader>c";
      action.__raw = "require('dap').continue";
    }
    {
      mode = "n";
      key = "<leader>C";
      action.__raw = "require('dap').run_to_cursor";
    }
    {
      mode = "n";
      key = "<leader>b";
      action.__raw = "require('dap').toggle_breakpoint";
    }

    # fzf
    {
      mode = "n";
      key = "<leader><leader>";
      action.__raw = "require('fzf-lua').resume";
    }
    {
      mode = "n";
      key = "<leader>gl";
      action.__raw = "require('fzf-lua').git_commits";
    }
    {
      mode = "n";
      key = "<leader>gf";
      action.__raw = "require('fzf-lua').git_bcommits";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action.__raw = "require('fzf-lua').files";
    }
    {
      mode = "n";
      key = "<leader>gg";
      action.__raw = "require('fzf-lua').git_files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action.__raw = "require('fzf-lua').live_grep";
    }
    {
      mode = "n";
      key = "<leader>gg";
      action.__raw = "require('fzf-lua').git_files";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action.__raw = "require('fzf-lua').grep_cword";
    }
    {
      mode = "v";
      key = "<leader>fr";
      action.__raw = "require('fzf-lua').grep_visual";
    }
    {
      mode = "n";
      key = "<leader>;";
      action.__raw = "require('fzf-lua').commands";
    }
    {
      mode = "n";
      key = "<leader>b";
      action.__raw = "require('fzf-lua').buffers";
    }
    {
      mode = "n";
      key = "<leader>l";
      action.__raw = "require('fzf-lua').lines";
    }
    {
      mode = "n";
      key = "<leader>gb";
      action.__raw = "require('fzf-lua').git_branches";
    }
    {
      mode = "n";
      key = "<leader>h";
      action.__raw = "require('fzf-lua').help_tags";
    }

    # git
    {
      mode = "n";
      key = "<leader>gq";
      action.__raw = ''require("gitsigns").setqflist'';
    }
    {
      mode = "n";
      key = "<leader>gA";
      action.__raw = ''require("gitsigns").stage_buffer'';
    }
    {
      mode = "n";
      key = "<leader>gR";
      action.__raw = ''require("gitsigns").reset_buffer'';
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>ga";
      action.__raw = ''require("gitsigns").stage_hunk'';
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>gr";
      action.__raw = ''require("gitsigns").reset_hunk'';
    }
    {
      mode = "n";
      key = "<leader>gu";
      action.__raw = ''require("gitsigns").undo_stage_hunk'';
    }
    {
      mode = "n";
      key = "<leader>gp";
      action.__raw = ''require("gitsigns").preview_hunk'';
    }
    {
      mode = "n";
      key = "<leader>gm";
      action.__raw =
        ''function() require("gitsigns").blame_line({ full = true }) end'';
    }
    {
      mode = "n";
      key = "<leader>gs";
      action.__raw = ''require("neogit").open'';
    }

    # lsp
    {
      mode = "n";
      key = "gD";
      action.__raw = "vim.lsp.buf.declaration";
    }
    {
      mode = "n";
      key = "gd";
      action.__raw = "vim.lsp.buf.definition";
    }
    {
      mode = [ "n" "i" ];
      key = "<C-s>";
      action.__raw = "vim.lsp.buf.signature_help";
    }
    {
      mode = [ "n" "i" ];
      key = "<C-t>";
      action.__raw =
        "vim.lsp.buf.hover, { buffer = 0, noremap = true, silent = true }";
    }
    {
      mode = "n";
      key = "<leader>rr";
      action.__raw = "vim.lsp.buf.references";
    }
    {
      mode = "n";
      key = "<leader>ro";
      action.__raw = "vim.lsp.buf.rename";
    }
    {
      mode = "n";
      key = "<leader>re";
      action.__raw = "vim.lsp.buf.code_action";
    }
    {
      mode = "n";
      key = "<leader>rn";
      action.__raw = "vim.diagnostic.goto_next";
    }
    {
      mode = "n";
      key = "<leader>rp";
      action.__raw = "vim.diagnostic.goto_prev";
    }
    {
      mode = "n";
      key = "<leader>rd";
      action.__raw = "vim.diagnostic.setqflist";
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>rf";
      action.__raw = "function() vim.lsp.buf.format({ async = true}) end";
    }

    # buffers
    {
      mode = "n";
      key = "<leader>q";
      action = "<cmd>bd<cr>";
    }
    {
      mode = "n";
      key = "<leader>Q";
      action = "<cmd>q!<cr>";
    }

    # quickfix
    {
      mode = "n";
      key = "<C-p>";
      action = "<cmd>cprev<cr>zz";
    }
    {
      mode = "n";
      key = "<C-n>";
      action = "<cmd>cnext<cr>zz";
    }
    {
      mode = "n";
      key = "<C-q>";
      action = "<cmd>copen<cr>";
    }
    {
      mode = "n";
      key = "<C-c>";
      action = "<cmd>cclose<cr>";
    }

    {
      mode = "n";
      key = "<leader>as";
      action.__raw = "require('persisted').load";
    }

    {
      mode = "n";
      key = "<leader>ft";
      action.__raw = ''require("yazi").yazi'';
    }

    # neotest
    {
      mode = "n";
      key = "<leader>tt";
      action.__raw = "function() require('neotest').run.run() end ";
    }
    {
      mode = "n";
      key = "<leader>tf";
      action.__raw =
        ''function() require('neotest').run.run(vim.fn.expand("%")) end '';
    }
    {
      mode = "n";
      key = "<leader>td";
      action.__raw =
        ''function() require('neotest').run.run({ strategy = "dap" ; }) end'';
    }
    {
      mode = "n";
      key = "<leader>ts";
      action.__raw = "require('neotest').summary.open";
    }
    {
      mode = "n";
      key = "<leader>gt";
      action.__raw = "require('tardis-nvim').tardis";
    }

    # neogen
    {
      mode = "n";
      key = "<leader>d";
      action.__raw = "require('neogen').generate";
    }
  ];
  };
}
