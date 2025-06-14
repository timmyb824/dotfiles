-- Bufferline version 1
-- return {
--   "akinsho/bufferline.nvim",
--   dependencies = { "nvim-tree/nvim-web-devicons" },
--   version = "*",
--   opts = {
--     options = {
--       mode = "tabs",
--       separator_style = "slant",
--     },
--   },
-- }

-- Bufferline version 2
return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	config = function()
        require("bufferline").setup {
            options = {
                numbers = "ordinal",
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        text_align = "center",
                    },
                },
                hover = {
					enabled = true,
					delay = 150,
					reveal = { "close" },
				},
                mappings = true,
                show_buffer_close_icons = true,
                show_close_icon = true,
                show_tab_indicators = true,
                separator_style = "slant",
                tab_size = 18,
                max_name_length = 18,
                max_prefix_length = 15,
                tab_label = "",
                color_icons = true,
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local s = " "
                    for e, n in pairs(diagnostics_dict) do
                        local sym = e == "error" and "" or (e == "warning" and "" or "")
                        s = s .. n .. sym
                    end
                    return s
                end,
            },
        }
    end,
}

-- Cokeline is a fork of bufferline
-- return {
--     require("lazy").setup({
--       {
--       "willothy/nvim-cokeline",
--       dependencies = {
--         "nvim-lua/plenary.nvim",        -- Required for v0.4.0+
--         "nvim-tree/nvim-web-devicons", -- If you want devicons
--       --  "stevearc/resession.nvim"       -- Optional, for persistent history
--       },
--       config = true
--     }
--     })
-- }
