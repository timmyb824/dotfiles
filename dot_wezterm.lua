-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = 'Tokyo Night'

config.font = wezterm.font(
    "BerkeleyMono Nerd Font Mono Plus Font Awesome Plus Octicons Plus Power Symbols Plus Codicons Plus Pomicons Plus Font Logos Plus Material Design Icons Plus Weather Icons",
    {
        weight = 'Bold'
    })
config.font_size = 16

config.enable_tab_bar = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0 -- 0.75
config.macos_window_background_blur = 0 -- 8

config.keys = { -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
{
    key = "LeftArrow",
    mods = "OPT",
    action = wezterm.action {
        SendString = "\x1bb"
    }
}, -- Make Option-Right equivalent to Alt-f; forward-word
{
    key = "RightArrow",
    mods = "OPT",
    action = wezterm.action {
        SendString = "\x1bf"
    }
}}

-- and finally, return the configuration to wezterm
return config
