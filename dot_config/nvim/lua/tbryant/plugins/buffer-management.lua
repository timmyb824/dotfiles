return {
    'j-morano/buffer_manager.nvim',
    dependancies = {
        'nvim-lua/plenary.nvim',
        config = function()
            require("cheatsheet").setup({
                line_keys = "1234567890",
                select_menu_item_commands = {
                    edit = {
                        key = "<CR>",
                        command = "edit"
                    }
                },
                focus_alternate_buffer = false,
                short_file_names = false,
                short_term_names = false,
                loop_nav = true,
                highlight = "",
                win_extra_options = {},
                borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
                format_function = nil,
                order_buffers = nil,
                show_indicators = nil
            })
        end
    }
}
