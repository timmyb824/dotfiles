-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = 'FirefoxDev'

-- Overwrrite the color_scheme with custom colors
config.colors = {
    background = "#000000",
    foreground = "#8ea0b3",
}

config.font = wezterm.font(
    "TX02 Nerd Font",
    {
        weight = 'ExtraBold'
    })
config.font_size = 16

config.enable_tab_bar = true

config.window_decorations = "TITLE | RESIZE"
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
