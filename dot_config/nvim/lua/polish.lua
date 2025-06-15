-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-----------------------------------------------
--------------------OPTIONS--------------------
-----------------------------------------------
vim.g.python3_host_prog = vim.fn.expand("~/uv/virtualenvs/neovim/bin/python")
vim.g.ruby_host_prog = vim.fn.expand("~/.rbenv/versions/3.2.1/bin/neovim-ruby-host")
vim.g.loaded_perl_provider = 0

-----------------------------------------------
--------------------HIGHLIGHTS-----------------
-----------------------------------------------
-- Set window separator and terminal highlights
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#4B5563" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "#1f2335" })
