-- Globals
vim.g.foldenable = false
vim.g.mapleader = " "
vim.opt.cmdheight = 0
vim.opt.completeopt = "menuone,noinsert"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.expandtab = true
vim.opt.fixeol = false
vim.opt.foldenable = false
vim.opt.guifont = "{{ fonts.monospace }}:h10"
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.inccommand = "nosplit"
vim.opt.jumpoptions = "stack"
vim.opt.laststatus = 3
vim.opt.mousemodel = "extend"
vim.opt.number = true
vim.opt.scrollback = 100000
vim.opt.scrolloff = 15
vim.opt.shiftwidth = 4
vim.opt.signcolumn = "yes:1"
vim.opt.smartcase = true
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.wildmode = "longest,list"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({
    spec = {
        -- theme
        { "rebelot/kanagawa.nvim", config = true },

        -- neotest
        {
            "nvim-neotest/neotest",
            config = function()
                local neotest = require("neotest")
                neotest.setup({
                    adapters = {
                        require("neotest-ctest").setup({
                            frameworks = { "catch2" },
                            dap_adapter = { "gdb" },
                            is_test_file = function(file)
                                local cwd = vim.uv.cwd()
                                return file:match(cwd .. "/test/.*cpp$") ~= nil
                            end,
                        }),
                        require("neotest-python"),
                    },
                })
                vim.keymap.set("n", "<leader>tt", neotest.run.run)
                vim.keymap.set("n", "<leader>ts", neotest.summary.open)
                vim.keymap.set("n", "<leader>td", function() neotest.run.run({ strategy = "dap" }) end)
            end,
            keys = { "<leader>tt", "<leader>ts", "<leader>td" },
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-treesitter/nvim-treesitter",
                "nvim-neotest/nvim-nio",
                "nvim-neotest/neotest-python",
                "orjangj/neotest-ctest",
            }
        },

        -- dap
        {
            "mfussenegger/nvim-dap",
            config = function()
                local dap = require("dap")
                local make_gdb_config = function(program)
                    return {
                        args = { "--quiet", "--interpreter=dap", "--eval-command", "set print pretty on" },
                        command = program,
                        type = "executable",
                    }
                end

                dap.adapters = {
                    bash = { command = "bash-debug-adapter", type = "executable" },
                    cmake = {
                        executable = { args = { "--debugger", "--debugger-pipe", "${pipe}" }, command = "cmake" },
                        pipe = "${pipe}",
                        type = "pipe",
                    },
                    gdb = make_gdb_config("gdb"),
                    python = {
                        executable = {
                            command = "python",
                            args = { "-m", "debugpy", "--listen", ":${port}" },
                        },
                        type = "server",
                        port = "${port}"
                    },
                }

                vim.keymap.set("n", "<leader>n", dap.step_over)
                vim.keymap.set("n", "<leader>i", dap.step_into)
                vim.keymap.set("n", "<leader>o", dap.step_out)
                vim.keymap.set("n", "<leader>c", dap.continue)
                vim.keymap.set("n", "<leader>C", dap.run_to_cursor)
                vim.keymap.set("n", "<leader>d", dap.terminate)
                vim.keymap.set("n", "<S-b>", dap.toggle_breakpoint)

                require("dap.ext.vscode").type_to_filetypes = { gdb = { "c", "cpp" } }
            end,
            keys = {
                "<leader>n",
                "<leader>i",
                "<leader>o",
                "<leader>c",
                "<leader>C",
                "<leader>d",
                "<S-b>",
            },
        },
        {
            "igorlfs/nvim-dap-view",
            opts = {
                auto_toggle = true,
                winbar = {
                    sections = {
                        "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "disassembly",
                    }
                }
            },
            dependencies = { "mfussenegger/nvim-dap" }
        },
        {
            "jorenar/nvim-dap-disasm",
            config = true,
            opts = {
                dapview_register = true,
                dapview = {
                    keymap = "D",
                    label = "Disassembly",
                    short_label = "󰒓 [D]",
                },
            },
            dependencies = { "mfussenegger/nvim-dap", "igorlfs/nvim-dap-view" }
        },

        -- fzf
        {
            "ibhagwan/fzf-lua",
            config = function()
                local fzf_lua = require("fzf-lua")
                fzf_lua.setup({ winopts = { preview = { layout = "horizontal" }, split = "belowright new" }, })

                fzf_lua.register_ui_select()
                vim.keymap.set("v", "<leader>fr", fzf_lua.grep_visual)
                vim.keymap.set("n", "<leader><leader>", fzf_lua.resume)
                vim.keymap.set("n", "<leader>fp", fzf_lua.tabs)
                vim.keymap.set("n", "<leader>gl", fzf_lua.git_commits)
                vim.keymap.set("n", "<leader>ff", fzf_lua.files)
                vim.keymap.set("n", "<leader>gg", fzf_lua.git_files)
                vim.keymap.set("n", "<leader>fg", fzf_lua.live_grep)
                vim.keymap.set("n", "<leader>fr", fzf_lua.grep_cword)
                vim.keymap.set("n", "<leader>;", fzf_lua.commands)
                vim.keymap.set("n", "<leader>b", fzf_lua.buffers)
                vim.keymap.set("n", "<leader>l", fzf_lua.lines)
                vim.keymap.set("n", "<leader>h", fzf_lua.help_tags)
            end,
            keys = {
                "<leader>fr",
                "<leader><leader>",
                "<leader>fp",
                "<leader>gl",
                "<leader>ff",
                "<leader>gg",
                "<leader>fg",
                "<leader>fr",
                "<leader>;",
                "<leader>b",
                "<leader>l",
                "<leader>h",
            }
        },

        -- git
        {
            "neogitorg/neogit",
            opts = {
                auto_show_console = false,
                disable_builtin_notifications = true,
                disable_commit_confirmation = true,
                kind = "split",
                use_magit_keybinds = true,
            },
            dependencies = { "nvim-lua/plenary.nvim" },
            config = function()
                vim.keymap.set("n", "<leader>gs", function() require("neogit").open({ kind = "replace" }) end)
            end,
            keys = { "<leader>gs" }
        },
        {
            "lewis6991/gitsigns.nvim",
            config = function()
                local gitsigns = require("gitsigns")
                vim.keymap.set("n", "<leader>gq", gitsigns.setqflist)
                vim.keymap.set("n", "<leader>gA", gitsigns.stage_buffer)
                vim.keymap.set("n", "<leader>gR", gitsigns.reset_buffer)
                vim.keymap.set({ "n", "v" }, "<leader>ga", gitsigns.stage_hunk)
                vim.keymap.set({ "n", "v" }, "<leader>gr", gitsigns.reset_hunk)
                vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk)
                vim.keymap.set("n", "<leader>gb", gitsigns.blame)
                vim.keymap.set("n", "<leader>gm", function() gitsigns.blame_line({ full = true }) end)
            end
        },

        -- misc
        {
            "fredehoey/tardis.nvim",
            config = function() vim.keymap.set("n", "<leader>gt", require("tardis-nvim").tardis) end,
            keys = { "<leader>gt" },
        },
        { "kevinhwang91/nvim-bqf", config = true },
        {
            "mikavilpas/yazi.nvim",
            config = function()
                vim.keymap.set("n", "<leader>ft", require("yazi").yazi)
            end,
            keys = { "<leader>ft" },
            dependencies = { "nvim-lua/plenary.nvim", "muniftanjim/nui.nvim", "nvim-tree/nvim-web-devicons", },
        },
        {
            "nvim-lualine/lualine.nvim",
            opts = {
                options = { disabled_filetypes = { winbar = { "dap-repl", "dap-view", "dap-view-term" } } } },
            config = true,
            dependencies = { "nvim-tree/nvim-web-devicons" }
        },
        {
            "olimorris/persisted.nvim",
            config = function()
                vim.keymap.set("n", "<leader>as", require("persisted").load)
            end,
            dependencies = { "nvim-lua/plenary.nvim" }
        },
        { "t-troebst/perfanno.nvim", config = true, dependencies = { "nvim-lua/plenary.nvim" } },
        { "aserowy/tmux.nvim",       config = true, },
        {
            "olimorris/codecompanion.nvim",
            opts = {
                interactions = {
                    chat = {
                        adapter = "opencode",
                    },
                },
            },
        },

        -- lsp
        {
            'saghen/blink.cmp',
            -- optional: provides snippets for the snippet source
            dependencies = { 'rafamadriz/friendly-snippets' },

            -- use a release tag to download pre-built binaries
            version = '1.*',
            opts = {
                keymap = { preset = "enter" },

                appearance = {
                    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                    -- Adjusts spacing to ensure icons are aligned
                    nerd_font_variant = 'mono'
                },

                -- (Default) Only show the documentation popup when manually triggered
                completion = { documentation = { auto_show = false } },
                sources = {
                    default = { 'lsp', 'path', 'snippets', 'buffer' },
                },
                fuzzy = { implementation = "prefer_rust_with_warning" }
            },
            opts_extend = { "sources.default" }
        },
        {
            "neovim/nvim-lspconfig",
            config = function()
                vim.lsp.config("bashls", {})
                vim.lsp.enable("bashls")
                vim.lsp.config("clangd", {
                    filetypes = { "c", "cpp" },
                    cmd = {
                        "clangd",
                        "--header-insertion=never",
                        "--all-scopes-completion",
                        "--background-index",
                        "--clang-tidy",
                        "--compile-commands-dir=build",
                        "--query-driver=/**/*",
                    },
                })
                vim.lsp.enable("clangd")
                vim.lsp.config("dartls", { cmd = { "fvm", "dart", "language-server", "--protocol=lsp" } })
                vim.lsp.enable("dartls")
                vim.lsp.config("docker_compose_language_service", {})
                vim.lsp.enable("docker_compose_language_service")
                vim.lsp.config("dockerls", {})
                vim.lsp.enable("dockerls")
                vim.lsp.config("ginko_ls", {})
                vim.lsp.enable("ginko_ls")
                vim.lsp.config("gopls", {})
                vim.lsp.enable("gopls")
                vim.lsp.config("lua_ls", {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" },
                            },
                            workspace = {
                                checkThirdParty = false,
                                library = vim.api.nvim_get_runtime_file("", true),
                            },
                        },
                    },
                })
                vim.lsp.enable("lua_ls")
                vim.lsp.config("neocmake", {})
                vim.lsp.enable("neocmake")
                vim.lsp.config("nixd", {})
                vim.lsp.enable("nixd")
                vim.lsp.config("pyright", {})
                vim.lsp.enable("pyright")
                vim.lsp.config("ruff", {})
                vim.lsp.enable("ruff")
                vim.lsp.config("rust_analyzer", {})
                vim.lsp.enable("rust_analyzer")
                vim.lsp.config("svelte", {})
                vim.lsp.enable("svelte")
                vim.lsp.config("terraformls", {})
                vim.lsp.enable("terraformls")
                vim.lsp.config("ty", {})
                vim.lsp.enable("ty")
                vim.lsp.config("ts_ls", {
                    filetypes = {
                        "javascript",
                        "javascriptreact",
                        "javascript.jsx",
                        "typescript",
                        "typescriptreact",
                        "typescript.tsx",
                    },
                })
                vim.lsp.enable("ts_ls")
                vim.lsp.config("verible", {})
                vim.lsp.enable("verible")
                vim.lsp.config("zls", {})
                vim.lsp.enable("zls")
                vim.lsp.config("zuban", {})
                vim.lsp.enable("zuban")
            end
        },

        -- treesitter

        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            opts = {
                highlight = { enable = true },
                incremental_selection = { enable = true },
                indent = { enable = false },
            }
        },

        {
            "mfussenegger/nvim-treehopper",
            config = function()
                vim.keymap.set({ 'v', 'o' }, 'm', require('tsht').nodes, { remap = false })
            end,
        },
        -- c++
        {
            "civitasv/cmake-tools.nvim",
            config = function()
                require("cmake-tools").setup({
                    cmake_dap_configuration = {
                        console = "integratedTerminal",
                        name = "cpp",
                        request = "launch",
                        runInTerminal = true,
                        stopOnEntry = false,
                        type = "gdb",
                    },
                    cmake_notifications = { executor = { enabled = false }, runner = { enabled = false } },
                    cmake_runner = { opts = { terminal = { split_direction = "vertical", split_size = 30 } } },
                })
            end,
            dependencies = { "nvim-lua/plenary.nvim" }
        },
        { "p00f/clangd_extensions.nvim", config = true },

    }
})

vim.cmd.colorscheme("kanagawa")


vim.diagnostic.config({ virtual_text = false })
vim.keymap.set('n', 'gK', function()
    local new_config = not vim.diagnostic.config().virtual_lines
    vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = 'Toggle diagnostic virtual_lines' })

-- misc keybinds
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l")
vim.keymap.set("t", "<esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<leader>j", "<cmd>vsplit term://${SHELL}<cr>")
vim.keymap.set("n", "<leader>k", "<cmd>split term://${SHELL}<cr>")
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "<C-s>", vim.lsp.buf.signature_help)
vim.keymap.set({ "n", "i" }, "<C-t>", vim.lsp.buf.hover, { buffer = 0, noremap = true, silent = true })
vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>ro", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>re", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>rn", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>rp", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>rd", vim.diagnostic.setqflist)
vim.keymap.set({ "n", "v" }, "<leader>rf", function() vim.lsp.buf.format({ async = true }) end)
vim.keymap.set("n", "<leader>q", "<cmd>bd<cr>")
vim.keymap.set("n", "<leader>Q", "<cmd>q!<cr>")
vim.keymap.set("n", "<C-p>", "<cmd>cprev<cr>zz")
vim.keymap.set("n", "<C-n>", "<cmd>cnext<cr>zz")
vim.keymap.set("n", "<C-q>", "<cmd>copen<cr>")
vim.keymap.set("n", "<C-c>", "<cmd>cclose<cr>")


vim.api.nvim_create_augroup("bun", { clear = true })

local autocmds = {
    {
        callback = function(args)
            local path = string.gsub(args.file, "(.*/)(.*)", "%1")
            if path == args.file then
                return
            end
            if not vim.loop.fs_stat(path) then
                vim.fn.system({ "mkdir", "-p", path })
            end
        end,
        event = { "BufWritePre" },
        group = "bun",
    },
    { command = "startinsert", event = { "TermOpen" }, group = "bun" },
}

for _, autocmd in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(autocmd.event, {
        group = autocmd.group,
        pattern = autocmd.pattern,
        buffer = autocmd.buffer,
        desc = autocmd.desc,
        callback = autocmd.callback,
        command = autocmd.command,
        once = autocmd.once,
        nested = autocmd.nested,
    })
end
