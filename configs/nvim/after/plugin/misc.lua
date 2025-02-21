-- general settings
vim.o.completeopt = 'menuone,noinsert,noselect'
vim.o.expandtab = true
vim.o.hidden = true
vim.o.ignorecase = true
vim.o.nu = true
vim.o.scrolloff = 15
vim.o.shiftwidth = 4
vim.o.smartcase = true
vim.o.tabstop = 4
vim.o.wildmode = 'longest,list'
vim.o.laststatus = 3
vim.o.inccommand = 'nosplit'
vim.o.termguicolors = true
vim.o.fixeol = false
vim.o.signcolumn = 'yes:1'
vim.o.guifont = 'Iosevka Nerd Font:h10'
vim.o.mousemodel = 'extend'
vim.o.cmdheight = 0
vim.g.foldenable = false
vim.o.jumpoptions = 'stack'
vim.o.scrollback = 100000
vim.o.foldenable = false
vim.o.undofile = true

local m = require('functions.keymap')

m.keys({ -- vblock moves
    { 'v', 'K', [[:m '<-2<cr>gv=gv]] },
    { 'v', 'J', [[:m '>+1<cr>gv=gv]] },
    { 'v', '<', [[<gv]] },
    { 'v', '>', [[>gv]] },
})

m.keys({
    { 'v', 'p', '"_dP' },
})

m.keys({ -- closing files
    { 'n', '<leader>q', [[<cmd>bd<cr>]] },
    { 'n', '<leader>Q', [[<cmd>q!<cr>]] },
})

m.keys({ -- qfl
    { 'n', '<C-p>', [[<cmd>cprev<cr>zz]] },
    { 'n', '<C-n>', [[<cmd>cnext<cr>zz]] },
    { 'n', '<C-q>', [[<cmd>copen<cr>]] },
    { 'n', '<C-c>', [[<cmd>cclose<cr>]] },
})

m.keys({ -- misc
    { 'n', 'gf', 'gF' },
    { 'n', '<leader>ft', [[<cmd>Triptych<cr>]] }
})

m.keys({
    { 't', '<C-h>', '<C-\\><C-N><C-w>h' },
    { 't', '<C-j>', '<C-\\><C-N><C-w>j' },
    { 't', '<C-k>', '<C-\\><C-N><C-w>k' },
    { 't', '<C-l>', '<C-\\><C-N><C-w>l' },
    { 't', '<esc>', '<C-\\><C-n>' },
})

for _, cmd in ipairs({ '<C-d>', '<C-u>', '<C-i>', '<C-o>', 'n', 'N', '*', '%' }) do
    m.key('n', cmd, cmd .. 'zz')
end

-- close vim if only the qfl is open
vim.api.nvim_create_autocmd('WinEnter', {
    command = [[if winnr('$') == 1 && &buftype == 'quickfix' | q | endif]],
})

vim.notify = require('notify')

m.keys({
    { 'n', '<leader>gt', require('tardis-nvim').tardis },
})

require('Comment').setup()
local ft = require('Comment.ft')
ft.cpp = { '// %s', '// %s' }
ft.c = { '// %s', '// %s' }

local group = vim.api.nvim_create_augroup('BunConfig', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    callback = function(args)
        local path = string.gsub(args.file, '(.*/)(.*)', '%1')
        if path == args.file then
            return
        end
        if not vim.loop.fs_stat(path) then
            vim.fn.system({ 'mkdir', '-p', path })
        end
    end,
})

local neotest = require('neotest')
neotest.setup {
    adapters = {
        require('neotest-python') {
            args = { '--log-level', 'DEBUG' },
            runner = 'pytest',
            python = '.venv/bin/python',
        },
        require('neotest-ctest').setup {}
    }
}

m.keys {
    { 'n', '<leader>tt', function() neotest.run.run() end },
    { 'n', '<leader>tf', function() neotest.run.run(vim.fn.expand('%')) end },
    { 'n', '<leader>td', function() neotest.run.run({ strategy = "dap" }) end }
}

require('cmake-tools').setup {
    cmake_regenerate_on_save = false,
    cmake_build_directory = 'build',
    cmake_dap_configuration = {
        name = 'cpp',
        type = 'gdb',
        request = 'launch',
        stopOnEntry = 'false',
        runInTerminal = 'true',
        console = 'integratedTerminal',
    },
}

m.keys_for_filetype({
    { 'cpp', 'n', '<leader>cc', function() require('cmake-tools').build({}) end },
    { 'cpp', 'n', '<leader>ct', function() require('cmake-tools').build({target = 'tests'}) end },
})
