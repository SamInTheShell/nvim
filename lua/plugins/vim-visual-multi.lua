return {
	"mg979/vim-visual-multi",
	branch = "master",
	keys = {
		{ "<C-p>", "<Plug>(VM-Find-Under)", desc = "Select word under cursor" },
	},
	config = function()
		-- Default keybindings:
		-- Ctrl-n: select word under cursor and add next match
		-- Ctrl-Down/Ctrl-Up: add cursors vertically  
		-- \\A: select all occurrences of word
		
		-- These are the default mappings
		vim.g.VM_maps = {
			["Find Under"] = "<C-n>",
			["Find Subword Under"] = "<C-n>",
			["Find Prev"] = "<C-p>",   -- When in VM mode, Ctrl+p finds previous
			["Select All"] = "\\A",
			["Add Cursor Down"] = "<C-Down>",
			["Add Cursor Up"] = "<C-Up>",
		}
	end,
}