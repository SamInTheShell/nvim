return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"goolord/alpha-nvim",
	},
	config = function()
		-- disable netrw at the very start of your init.lua
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- optionally enable 24-bit colour
		vim.opt.termguicolors = true

		-- Custom on_attach function to handle alpha closing
		local function on_attach(bufnr)
			local api = require("nvim-tree.api")

			local function opts(desc)
				return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			-- Apply default mappings first
			api.config.mappings.default_on_attach(bufnr)

			-- Function to close alpha before opening file (only for actual files, not folders)
			local function close_alpha_and_open_file(open_fn)
				return function()
					local node = api.tree.get_node_under_cursor()
					-- Only close alpha if we're opening a file, not a folder
					if node and node.type == "file" then
						-- Check if alpha is visible and close it
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.api.nvim_buf_get_option(buf, "filetype") == "alpha" then
								vim.api.nvim_win_close(win, false)
								break
							end
						end
					end
					-- Then perform the original action
					open_fn()
				end
			end

			-- Override file opening keymaps to close alpha first
			vim.keymap.set("n", "<CR>", close_alpha_and_open_file(api.node.open.edit), opts("Open"))
			vim.keymap.set("n", "o", close_alpha_and_open_file(api.node.open.edit), opts("Open"))
			vim.keymap.set("n", "<2-LeftMouse>", close_alpha_and_open_file(api.node.open.edit), opts("Open"))
			vim.keymap.set("n", "v", close_alpha_and_open_file(api.node.open.vertical), opts("Open: Vertical Split"))
			vim.keymap.set(
				"n",
				"h",
				close_alpha_and_open_file(api.node.open.horizontal),
				opts("Open: Horizontal Split")
			)
			vim.keymap.set("n", "t", close_alpha_and_open_file(api.node.open.tab), opts("Open: New Tab"))
			
			-- Add width resize keymaps (only for nvim-tree)
			vim.keymap.set("n", ">", function()
				local win = vim.api.nvim_get_current_win()
				local current_width = vim.api.nvim_win_get_width(win)
				vim.api.nvim_win_set_width(win, current_width + 5)
			end, opts("Increase Width"))
			
			vim.keymap.set("n", "<", function()
				local win = vim.api.nvim_get_current_win()
				local current_width = vim.api.nvim_win_get_width(win)
				vim.api.nvim_win_set_width(win, math.max(10, current_width - 5)) -- Minimum width of 10
			end, opts("Decrease Width"))
		end

		-- OR setup with some options
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
			on_attach = on_attach,
		})

		-- Auto-open NvimTree only when no file is provided
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				-- Only open tree if no arguments were passed (no files specified)
				if vim.fn.argc() == 0 then
					require("nvim-tree.api").tree.open()
					vim.cmd("wincmd l") -- Focus right window (editor)
				end
			end,
		})

		vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>")

		-- Re-open Alpha when only NvimTree is left instead of closing
		-- Add a flag to prevent recursive trap during quit sequence
		local quitting = false
		local saved_tree_width = 60 -- Default width, will be updated when user resizes

		-- Track nvim-tree width when there are multiple windows
		vim.api.nvim_create_autocmd("WinResized", {
			callback = function()
				if #vim.api.nvim_list_wins() > 1 then
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if require("nvim-tree.utils").is_nvim_tree_buf(vim.api.nvim_win_get_buf(win)) then
							saved_tree_width = vim.api.nvim_win_get_width(win)
							break
						end
					end
				end
			end,
		})

		vim.api.nvim_create_autocmd("BufEnter", {
			nested = true,
			callback = function()
				if quitting then
					return
				end
				-- Save tree width when we have multiple windows
				if #vim.api.nvim_list_wins() > 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
					saved_tree_width = vim.api.nvim_win_get_width(vim.api.nvim_get_current_win())
				end

				-- Only trigger if we have exactly 1 window and it's nvim-tree
				if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
					-- Defer the split to avoid the closing window error
					vim.schedule(function()
						if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
							local tree_win = vim.api.nvim_get_current_win()
							vim.cmd("vsplit")
							vim.cmd("enew")
							require("alpha").start(true)
							-- Restore nvim-tree width to saved width
							vim.api.nvim_win_set_width(tree_win, saved_tree_width)
						end
					end)
				end
			end,
		})

		-- Override alpha quit to close nvim-tree first
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "alpha",
			callback = function(args)
				vim.keymap.set("n", "q", function()
					print("CUSTOM QUIT OVERRIDE TRIGGERED")
				end, { buffer = args.buf, silent = true })
			end,
		})
	end,
}
