-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- sourcery and coc
keymap.set("n", "<leader>cl", "<cmd>CocDiagnostics<CR>", { desc = "Show Diagnostics" })
keymap.set("n", "<leader>ch", "<cmd>call CocAction('doHover')<CR>", { desc = "Show description of refactoring" })
keymap.set("n", "<leader>cf", "<plug>(coc-codeaction-cursor)", { desc = "Show code actions" }) -- show code actions
keymap.set(
	"n",
	"<leader>ca",
	"<cmd>call CocActionAsync('codeAction', 'cursor')<CR>",
	{ desc = "Accept code suggestion" }
) -- rename symbol
keymap.set("n", "<leader>ca", "<plug>(coc-fix-current)", { desc = "Fix current" }) -- fix current
keymap.set("n", "[c", "<plug>(coc-diagnostic-prev)", { desc = "Previous diagnostic" }) -- previous diagnostic
keymap.set("n", "]c", "<plug>(coc-diagnostic-next)", { desc = "Next diagnostic" }) -- next diagnostic

-- buffer management
keymap.set("n", "<leader>bs", "<cmd>Buffers<CR>", { desc = "Show buffers" }) -- show buffers
keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Close buffer" }) -- close buffer
keymap.set("n", "<leader>bn", "<cmd>bn<CR>", { desc = "Next buffer" }) -- next buffer
keymap.set("n", "<leader>bp", "<cmd>bp<CR>", { desc = "Previous buffer" }) -- previous buffer
keymap.set("n", "<leader>bl", "<cmd>ls<CR>", { desc = "List buffers" }) -- list buffers
keymap.set("n", "<leader>bf", "<cmd>Telescope buffers<CR>", { desc = "Find buffer" }) -- find buffer

-- oil.nvim
keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- which-key leader groups
keymap.set("n", "<leader>b", "<cmd><CR>", { desc = "buffers" }) -- list open buffers
keymap.set("n", "<leader>c", "<cmd><CR>", { desc = "code actions" }) -- code actions
keymap.set("n", "<leader>e", "<cmd><CR>", { desc = "file browser" }) -- list explorer
keymap.set("n", "<leader>f", "<cmd><CR>", { desc = "find files" }) -- fuzzy search
keymap.set("n", "<leader>g", "<cmd>LazyGit<CR>", { desc = "lazygit" }) -- lazygit
keymap.set("n", "<leader>m", "<cmd><CR>", { desc = "format code" }) -- format code
keymap.set("n", "<leader>n", "<cmd><CR>", { desc = "clear search" }) -- clear search
keymap.set("n", "<leader>s", "<cmd><CR>", { desc = "windows" }) -- window management
keymap.set("n", "<leader>t", "<cmd><CR>", { desc = "tabs" }) -- tab management
keymap.set("n", "<leader>w", "<cmd><CR>", { desc = "sessions" }) -- session management
keymap.set("n", "<leader>x", "<cmd><CR>", { desc = "troubleshoot" }) -- troubleshooting

-- better copy and paste
keymap.set("v", "<leader>y", '"+y', { desc = "Copy to clipboard" }) -- copy to clipboard
keymap.set("n", "<leader>p", "<cmd><CR>", { desc = "Paste from clipboard" }) -- paste from clipboard
keymap.set("n", "<leader>pc", '"+p', { desc = "Paste from clipboard" })
