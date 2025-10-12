return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			theme = "dracula",
			sections = {
				lualine_c = {
					{
						"filename",
						path = 3, -- 0 = just filename, 1 = relative path, 2 = absolute path, 3 = absolute path with ~ for home
					},
				},
			},
		})
	end,
}
