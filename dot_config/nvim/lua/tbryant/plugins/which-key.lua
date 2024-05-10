return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
    end,
    opts = {
        defaults = {
            ["<leader>c"] = {
                name = "+code"
            },
            ["<leader>e"] = {
                name = "+file explorer"
            },
            ["<leader>f"] = {
                name = "+fuzzy find"
            },
            ["<leader>m"] = {
                name = "+format visual mode"
            },
            ["<leader>n"] = {
                name = "+clear search"
            },
            ["<leader>s"] = {
                name = "+split windows"
            },
            ["<leader>t"] = {
                name = "+tab management"
            },
            ["<leader>w"] = {
                name = "+session"
            },
            ["<leader>x"] = {
                name = "+troubleshoot"
            }
        }
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
        wk.register(opts.defaults)
    end
}
