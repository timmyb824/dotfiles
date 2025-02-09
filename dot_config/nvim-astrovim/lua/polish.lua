-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-----------------------------------------------
--------------------OPTIONS--------------------
-----------------------------------------------
vim.g.python3_host_prog = vim.fn.expand('~/.pyenv/versions/neovim/bin/python')
vim.g.ruby_host_prog = vim.fn.expand('~/.rbenv/versions/3.2.1/bin/neovim-ruby-host')
vim.g.loaded_perl_provider = 0


-----------------------------------------------
--------------------FILETYPES------------------
-----------------------------------------------
-- Set up custom filetypes
vim.filetype.add {
  extension = {
    foo = "fooscript",
  },
  filename = {
    ["Foofile"] = "fooscript",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
  },
}
