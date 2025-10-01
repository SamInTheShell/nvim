vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.opt.numberwidth = 4
vim.opt.signcolumn = "yes:2"

-- Terminal-like keybindings for insert mode
-- Delete last word from normal mode
-- vim.keymap.set('n', '<C-w>', 'i<C-w>', { desc = 'Delete word backward' })

-- Jump cursor backwards already works
-- vim.keymap.set('n', '<M-Left>', '<C-Left>', { desc = 'Move word backward' })

-- Fix jump cursor forward
vim.keymap.set("n", "<Esc>f", "w", { desc = "Move word forward" })

-- Copy/paste in visual mode
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to system clipboard" })
-- vim.keymap.set('i', '<C-v>', '"+p', { desc = 'Paste from system clipboard' })

