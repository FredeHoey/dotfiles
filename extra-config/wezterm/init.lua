local wezterm = require('wezterm')

function tmux_running()
    local handle = io.popen('tmux list-sessions')
    if handle == nil then
        print('failed running tmux')
        return false
    end
    return handle:read('l') ~= nil
end

function tmux_command()
    local command = {'tmux'}
    if tmux_running() then
        table.insert(command, 'a')
    end
    return command
end

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.enable_tab_bar = false

config.default_prog = tmux_command()
return config
