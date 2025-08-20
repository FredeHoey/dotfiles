local wezterm = require('wezterm')
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.enable_tab_bar = false
return config
