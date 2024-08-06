--return {
--	"folke/which-key.nvim",
--	event = "VeryLazy",
--	init = function()
--		vim.o.timeout = true
--		vim.o.timeoutlen = 500
--	end,
--	opts = {
--		defaults = {
--			["<leader>b"] = {
--				name = "+buffers",
--			},
--			["<leader>c"] = {
--				name = "+code",
--			},
--			["<leader>e"] = {
--				name = "+explorer",
--			},
--			["<leader>f"] = {
--				name = "+fuzzy",
--			},
--			["<leader>l"] = {
--				name = "+lazygit",
--			},
--			["<leader>m"] = {
--				name = "+format",
--			},
--			["<leader>n"] = {
--				name = "+clear search",
--			},
--			["<leader>s"] = {
--				name = "+windows",
--			},
--			["<leader>t"] = {
--				name = "+tabs",
--			},
--			["<leader>w"] = {
--				name = "+session",
--			},
--			["<leader>x"] = {
--				name = "+troubleshoot",
--			},
--		},
--	},
--	config = function(_, opts)
--		local wk = require("which-key")
--		wk.setup(opts)
--		wk.register(opts.defaults)
--	end,
--}

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
