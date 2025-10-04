vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.opt.numberwidth = 4
vim.opt.signcolumn = "yes:2"
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Enable mouse support for native-like selection
vim.opt.mouse = "a"
vim.opt.mousefocus = true

-- System clipboard integration
vim.opt.clipboard = "unnamedplus"

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum"
vim.opt.pumheight = 10

-- New panels
vim.keymap.set("n", "<leader>n", ":new<CR>", { desc = "New window below current" })
vim.keymap.set("n", "<leader>N", ":vnew<CR>", { desc = "New window right of current" })
vim.keymap.set("n", "<leader>q", ":bd<CR>")
vim.keymap.set("n", "<leader>Q", ":bd!<CR>")
vim.keymap.set("n", "<leader>rh", ":horizontal resize ")
vim.keymap.set("n", "<leader>rv", ":vertical resize ")
vim.keymap.set("n", "<leader>rs", ":vertical resize 60<CR>")

-- Native-like copy/paste/cut shortcuts
-- Copy
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })

-- Paste
vim.keymap.set("n", "<D-v>", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("i", "<D-v>", "<C-r>+", { desc = "Paste from system clipboard" })
vim.keymap.set("c", "<D-v>", "<C-r>+", { desc = "Paste from system clipboard" })
vim.keymap.set("v", "<D-v>", '"+p', { desc = "Paste from system clipboard" })

-- Cut
vim.keymap.set("v", "<D-x>", '"+d', { desc = "Cut to system clipboard" })
vim.keymap.set("v", "<C-x>", '"+d', { desc = "Cut to system clipboard" })

-- Select all
vim.keymap.set("n", "<D-a>", "ggVG", { desc = "Select all" })

-- Better visual mode behavior
vim.keymap.set("v", "<", "<gv", { desc = "Indent and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Unindent and reselect" })

-- Fix Go comment block auto-indent
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		-- Add 'r' and 'o' to formatoptions for Go files:
		-- r: Insert comment leader when pressing Enter in Insert mode
		-- o: Insert comment leader when using 'o' or 'O' in Normal mode
		-- This enables auto-indent continuation in /* */ comment blocks
		vim.opt_local.formatoptions:append("ro")
	end,
})
