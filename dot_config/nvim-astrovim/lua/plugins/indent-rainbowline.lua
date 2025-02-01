-- return {
--     "lukas-reineke/indent-blankline.nvim",
--     opts = function(_, opts)
--         return require("indent-rainbowline").make_opts(opts, require("astrocore").plugin_opts "indent-rainbowline.nvim")
--     end,
--     dependencies = { "TheGLander/indent-rainbowline.nvim" },
-- }

return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = function(_, opts)
		-- Other blankline configuration here
		return require("indent-rainbowline").make_opts(opts)
	end,
	dependencies = {
		"TheGLander/indent-rainbowline.nvim",
	},
}
