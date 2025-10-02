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

-- Enable mouse support for native-like selection
vim.opt.mouse = "a"
vim.opt.mousefocus = true

-- System clipboard integration
vim.opt.clipboard = "unnamedplus"

-- Native-like copy/paste/cut shortcuts
-- Copy
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })

-- Paste
vim.keymap.set("n", "<D-v>", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("i", "<D-v>", '<C-r>+', { desc = "Paste from system clipboard" })
vim.keymap.set("c", "<D-v>", '<C-r>+', { desc = "Paste from system clipboard" })
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

