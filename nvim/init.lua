-- Globals
vim.g.foldenable = false
vim.g.mapleader = " "
vim.opt.cmdheight = 0
vim.opt.completeopt = "menuone,noinsert,noselect"
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

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local package_path = vim.fn.stdpath('data') .. '/site/'
local mini_path = package_path .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
        'git', 'clone', '--filter=blob:none',
        'https://github.com/nvim-mini/mini.nvim', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
end



-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = package_path } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- now(vim.cmd.colorscheme("main"))

now(function() require('mini.notify').setup() end)
now(function() require('mini.icons').setup() end)
now(function() require('mini.statusline').setup() end)

now(function() require('mini.comment').setup() end)
now(function() require('mini.completion').setup() end)
now(function() require('mini.diff').setup() end)
now(function() require('mini.snippets').setup() end)
now(function() require('mini.pairs').setup() end)


-- Core shared dependencies
now(function()
    add("nvim-lua/plenary.nvim")
    add("nvim-tree/nvim-web-devicons")
    add("nvim-neotest/nvim-nio")
    add("muniftanjim/nui.nvim")
    add("rebelot/kanagawa.nvim")
end)

vim.cmd.colorscheme("kanagawa")

add({ source = "aserowy/tmux.nvim" })
add({ source = "civitasv/cmake-tools.nvim", depends = { "nvim-lua/plenary.nvim" } })
add({ source = "danymat/neogen", depends = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" } })
add({ source = "fredehoey/tardis.nvim", name = "tardis-nvim" })
add({ source = "ibhagwan/fzf-lua" })
add({ source = "igorlfs/nvim-dap-view", name = "dap-view", depends = { "mfussenegger/nvim-dap" } })
add({ source = "kevinhwang91/nvim-bqf" })
add({ source = "mfussenegger/nvim-dap" })
add({ source = "mikavilpas/yazi.nvim", name = "yazi", depends = { "nvim-lua/plenary.nvim", "muniftanjim/nui.nvim", "nvim-tree/nvim-web-devicons" }, })
add({ source = "neogitorg/neogit", depends = { "nvim-lua/plenary.nvim" } })
add({ source = "neovim/nvim-lspconfig" })
add({ source = "nvim-lualine/lualine.nvim", depends = { "nvim-tree/nvim-web-devicons" } })
add({ source = "nvim-neotest/neotest", depends = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "nvim-neotest/nvim-nio" }, })
add({ source = "nvim-neotest/neotest-python", depends = { "nvim-neotest/neotest" } })
add({ source = "nvim-treesitter/nvim-treesitter", checkout = "master", hooks = { post_checkout = function() vim.cmd("TSUpdate") end }, })
add({ source = "olimorris/persisted.nvim", depends = { "nvim-lua/plenary.nvim" } })
add({ source = "orjangj/neotest-ctest", depends = { "nvim-neotest/neotest" } })
add({ source = "p00f/clangd_extensions.nvim" })
add({ source = "rachartier/tiny-inline-diagnostic.nvim" })
add({ source = "rcasia/neotest-bash", depends = { "nvim-neotest/neotest" } })
add({ source = "t-troebst/perfanno.nvim", depends = { "nvim-lua/plenary.nvim" } })


-- Safely execute immediately

vim.diagnostic.config({ virtual_text = false })


require("bqf").setup({})
require("perfanno").setup({})
require("persisted").setup({})
require("tardis-nvim").setup({})
require("tiny-inline-diagnostic").setup({})
require("tmux").setup({})
require("yazi").setup({})
require("neogen").setup({})

require("neotest").setup({
    adapters = {
        require("neotest-bash"),
        require("neotest-ctest").setup({
            frameworks = { "catch2" },
            is_test_file = function(file_path)
                return string.match(file_path, "test") ~= nil
            end,
        }),
        require("neotest-python"),
    },
})

require('nvim-treesitter').setup({
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enable = false },
})

require("neogit").setup({
    auto_show_console = false,
    disable_builtin_notifications = true,
    disable_commit_confirmation = true,
    kind = "split",
    use_magit_keybinds = true,
})


require("lualine").setup({ options = { disabled_filetypes = { winbar = { "dap-repl", "dap-view", "dap-view-term" } } } })

local fzf_lua = require("fzf-lua")
require("fzf-lua").setup({
    winopts = { border = "none", preview = { border = "none", layout = "horizontal" }, split = "belowright new" },
})
require("fzf-lua").register_ui_select()

require("dap-view").setup({ auto_toggle = true })

local dap = require("dap")
dap.adapters = {
    bash = { command = "bash-debug-adapter", type = "executable" },
    cmake = {
        executable = { args = { "--debugger", "--debugger-pipe", "${pipe}", "build" }, command = "cmake" },
        pipe = "${pipe}",
        type = "pipe",
    },
    gdb = {
        args = { "--quiet", "--interpreter=dap", "--eval-command", "set print pretty on" },
        command = "gdb",
        type = "executable",
    },
    python = { 
        executable = {
            command = "python",
            args = { "-m", "debugpy", "--listen", ":${port}", "${file}"},
        },
        type = "server",
        port = "${port}"
    },
}

require("dap.ext.vscode").type_to_filetypes = {
    gdb = { "c", "cpp" },
}

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

require("clangd_extensions").setup({})

vim.keymap.set("n", "<leader>n", require("dap").step_over)
vim.keymap.set("n", "<leader>i", require("dap").step_into)
vim.keymap.set("n", "<leader>o", require("dap").step_out)
vim.keymap.set("n", "<leader>c", require("dap").continue)
vim.keymap.set("n", "<leader>C", require("dap").run_to_cursor)
vim.keymap.set("n", "<S-b>", require("dap").toggle_breakpoint)
vim.keymap.set("v", "<leader>fr", fzf_lua.grep_visual)
vim.keymap.set("n", "<leader><leader>", fzf_lua.resume)
vim.keymap.set("n", "<leader>fp", fzf_lua.tabs)
vim.keymap.set("n", "<leader>gl", fzf_lua.git_commits)
vim.keymap.set("n", "<leader>ff", fzf_lua.files)
vim.keymap.set("n", "<leader>gg", fzf_lua.git_files)
vim.keymap.set("n", "<leader>fg", fzf_lua.live_grep)
vim.keymap.set("n", "<leader>gg", fzf_lua.git_files)
vim.keymap.set("n", "<leader>fr", fzf_lua.grep_cword)
vim.keymap.set("n", "<leader>;", fzf_lua.commands)
vim.keymap.set("n", "<leader>b", fzf_lua.buffers)
vim.keymap.set("n", "<leader>l", fzf_lua.lines)
vim.keymap.set("n", "<leader>gb", fzf_lua.git_branches)
vim.keymap.set("n", "<leader>h", fzf_lua.help_tags)
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l")
vim.keymap.set("t", "<esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<leader>j", "<cmd>vsplit term://${SHELL}<cr>")
vim.keymap.set("n", "<leader>k", "<cmd>split term://${SHELL}<cr>")
vim.keymap.set("n", "<leader>gs", require("neogit").open)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "<C-s>", vim.lsp.buf.signature_help)
vim.keymap.set({ "n", "i" }, "<C-t>", vim.lsp.buf.hover, { buffer = 0, noremap = true, silent = true })
vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>ro", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>re", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.code_action)
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
vim.keymap.set("n", "<leader>as", require("persisted").load)
vim.keymap.set("n", "<leader>ft", require("yazi").yazi)
vim.keymap.set("n", "<leader>tt", require("neotest").run.run)
vim.keymap.set("n", "<leader>ts", require("neotest").summary.open)
vim.keymap.set("n", "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end)
vim.keymap.set("n", "<leader>gt", require("tardis-nvim").tardis)
vim.keymap.set("n", "<leader>d", require("neogen").generate)


local default_caps = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- Capabilities configuration for blink-cmp
    capabilities = MiniCompletion.get_lsp_capabilities(capabilities)

    return capabilities
end


vim.lsp.config("bashls", {})
vim.lsp.enable("bashls")
vim.lsp.config("bitbake_language_server", {})
vim.lsp.enable("bitbake_language_server")
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
vim.lsp.config("dartls", {})
vim.lsp.enable("dartls")
vim.lsp.config("docker_compose_language_service", {})
vim.lsp.enable("docker_compose_language_service")
vim.lsp.config("dockerls", {})
vim.lsp.enable("dockerls")
vim.lsp.config("ginko_ls", {})
vim.lsp.enable("ginko_ls")
vim.lsp.config("gopls", {})
vim.lsp.enable("gopls")
vim.lsp.config("lua_ls", {})
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
    { command = "bd!", event = { "TermClose" }, group = "bun" },
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
