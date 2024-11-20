-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- https://codeium.com/profile?response_type=token&redirect_uri=vim-show-auth-token&state=77192587-1b37-4484-bb15-11c69020a05b&scope=openid%20profile%20email&redirect_parameters_type=query

vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard configuration
local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

local function is_shellfish_terminal()
  return vim.env.LC_TERMINAL == "ShellFish"
end

if executable("pbcopy") and executable("pbpaste") or is_shellfish_terminal() then
  vim.g.clipboard = {
    name = "myClipboard-pbcopy",
    copy = {
      ["+"] = { "pbcopy" },
      ["*"] = { "pbcopy" },
    },
    paste = {
      ["+"] = { "pbpaste" },
      ["*"] = { "pbpaste" },
    },
    cache_enabled = 1,
  }
elseif executable("xclip") then
  vim.g.clipboard = {
    name = "myClipboard-xclip",
    copy = {
      ["+"] = { "xclip", "-selection", "clipboard" },
      ["*"] = { "xclip", "-selection", "primary" },
    },
    paste = {
      ["+"] = { "xclip", "-selection", "clipboard", "-o" },
      ["*"] = { "xclip", "-selection", "primary", "-o" },
    },
    cache_enabled = 1,
  }
else
  -- fallback to unnamedplus if no clipboard tool is available
  opt.clipboard:append({ "unnamedplus" })
end

-- clipboard (original setting on macOS before the above logic was added)
-- opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- use python virtualenv
vim.cmd("let g:python3_host_prog = '~/.pyenv/versions/neovim/bin/python'")

-- use ruby virtualenv
vim.cmd("let g:ruby_host_prog = '~/.rbenv/versions/3.2.1/bin/neovim-ruby-host'")

-- disable perl provider
vim.cmd("let g:loaded_perl_provider = 0")

-- Automatically indent to the correct level when entering insert mode on a blank line
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    if vim.fn.getline(".") == "" and vim.bo.buftype == "" then -- Reject special buffers like telescope inputs
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-f>", true, true, true), "n", false)
    end
  end,
})
