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
vim.o.guifont = 'Iosevka:h10'
vim.o.mousemodel = 'extend'

local m = require('functions.keymap')

m.keys { -- undo tags
    { 'i', ',', [[<C-g>u,]] },
    { 'i', '.', [[<C-g>u.]] },
    { 'i', '!', [[<C-g>u!]] },
    { 'i', '?', [[<C-g>u?]] },
    { 'i', ';', [[<C-g>u;]] },
}

m.keys { -- vblock moves
    { 'v', 'K', [[:m '<-2<cr>gv=gv]] },
    { 'v', 'J', [[:m '>+1<cr>gv=gv]] },
    { 'v', '<', [[<gv]] },
    { 'v', '>', [[>gv]] },
}

m.keys { -- window actions
    { 'n', '<C-h>', '<C-w>h' },
    { 'n', '<C-j>', '<C-w>j' },
    { 'n', '<C-k>', '<C-w>k' },
    { 'n', '<C-l>', '<C-w>l' },
}

m.keys {
    {'v', 'p', '"_dP'}
}

m.keys { -- closing files
    { 'n', '<leader>q', [[<cmd>bw<cr>]] },
    { 'n', '<leader>Q', [[<cmd>q!<cr>]] },
}

m.keys { -- qfl
    { 'n', '<C-p>', [[<cmd>cprev<cr>zz]] },
    { 'n', '<C-n>', [[<cmd>cnext<cr>zz]] },
    { 'n', '<C-q>', [[<cmd>copen<cr>]] },
    { 'n', '<C-c>', [[<cmd>lclose | cclose<cr>]] },
    { 'n', '<M-p>', [[<cmd>lprev<cr>zz]] },
    { 'n', '<M-n>', [[<cmd>lnext<cr>zz]] },
    { 'n', '<M-q>', [[<cmd>lopen<cr>]] },
    { 'n', '<leader>l', [[<cmd>lvim // % | lopen<cr>]] }
}

local function open_config()
    local config_path = vim.fn.stdpath('config') .. '/init.lua'
    vim.cmd('e ' .. config_path)
end

m.keys { -- misc
    { 'n', '<leader>fe', open_config },
    { 'n', '<leader><leader>', [[<cmd>e term:///bin/bash<cr>]] },
    { 'n', '<leader>j', [[<cmd>vsplit term:///bin/bash<cr>]] },
    { 'n', '<leader>k', [[<cmd>split term:///bin/bash<cr>]] },
    { 'n', 'gf', 'gF' },
}

for _, cmd in ipairs { '<C-d>', '<C-u>', '<C-i>', '<C-o>', 'n', 'N', '*', '%' } do
    m.key('n', cmd, cmd .. 'zz', { noremap = true })
end

-- close vim if only the qfl is open
vim.api.nvim_create_autocmd('WinEnter', {
    command = [[if winnr('$') == 1 && &buftype == 'quickfix' | q | endif]]
})

vim.notify = require('notify')

-- osc52
local function copy(lines, _)
    require('osc52').copy(table.concat(lines, '\n'))
end

local function paste()
    return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
end

vim.g.clipboard = {
    name = 'osc52',
    copy = { ['+'] = copy, ['*'] = copy },
    paste = { ['+'] = paste, ['*'] = paste },
}

-- Now the '+' register will copy to system clipboard using OSC52
vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, { expr = true })
vim.keymap.set('n', '<leader>cc', '<leader>c_', { remap = true })
vim.keymap.set('x', '<leader>c', require('osc52').copy_visual)

-- terminal config
vim.o.scrollback = 100000

m.keys {
    { 't', '<C-h>', '<C-\\><C-N><C-w>h' },
    { 't', '<C-j>', '<C-\\><C-N><C-w>j' },
    { 't', '<C-k>', '<C-\\><C-N><C-w>k' },
    { 't', '<C-l>', '<C-\\><C-N><C-w>l' },
    { 't', '<esc>', '<C-\\><C-n>' },
}

vim.api.nvim_create_augroup('Terminal', { clear = true })
-- start terminal in insert mode
vim.api.nvim_create_autocmd('TermOpen', {
    command = 'setlocal nonumber norelativenumber | startinsert',
    group = 'Terminal'
})
-- close terminal buffer after command finishes
vim.api.nvim_create_autocmd('TermClose', {
    command = 'bw',
    group = 'Terminal'
})

-- treesitter
require('nvim-treesitter.configs').setup({
    -- Don't do the following without internet
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    matchup = { enable = true },
})

-- tree-climber/hopper
m.key('o', 'm', require('tsht').nodes, { remap = false })
m.key('x', 'm', require('tsht').nodes, { remap = true })

-- sessions
require('persisted').setup {
    dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"),
    use_git_branch = true,
}
vim.o.sessionoptions = "buffers,curdir,tabpages,winsize"

m.keys {
    { 'n', '<leader>as', require('persisted').load },
    { 'n', '<leader>ad', require('persisted').stop },
}
-- autopairs
require('nvim-autopairs').setup {
    check_ts = true,
}

require('Comment').setup()
local ft = require('Comment.ft')
ft.cpp = {'// %s', '// %s'}
ft.c = {'// %s', '// %s'}

m.keys {
    {'n', '<M-b>', function() require('functions.asyncmake').make() end }
}
