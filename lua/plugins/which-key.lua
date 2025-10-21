return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		win = {
			border = "rounded",
		},
		spec = {
			{ "<leader>f", group = "Find/File" },
			{ "<leader>g", group = "Git" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>t", group = "Terminal/Toggle" },
			{ "<leader>w", group = "Window" },
			{ "<leader>b", group = "Buffer" },
		},
	},
}