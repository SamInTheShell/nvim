return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		-- disable netrw at the very start of your init.lua
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- optionally enable 24-bit colour
		vim.opt.termguicolors = true

		require("nvim-tree").setup({
			sort = {
				sorter = "case_sensitive",
			},
			view = {
				width = 35,
			},
			renderer = {
				group_empty = true,
			},
			filters = {
				dotfiles = true,
			},
			filesystem_watchers = {
				enable = true,
			},
			actions = {
				change_dir = {
					restrict_above_cwd = true,
				},
			},
		})

		vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>")
	end,
}