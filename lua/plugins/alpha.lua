return {
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Function to interpolate between two colors
		local function lerp_color(color1, color2, t)
			local r1, g1, b1 =
				tonumber(color1:sub(2, 3), 16), tonumber(color1:sub(4, 5), 16), tonumber(color1:sub(6, 7), 16)
			local r2, g2, b2 =
				tonumber(color2:sub(2, 3), 16), tonumber(color2:sub(4, 5), 16), tonumber(color2:sub(6, 7), 16)
			local r = math.floor(r1 + (r2 - r1) * t)
			local g = math.floor(g1 + (g2 - g1) * t)
			local b = math.floor(b1 + (b2 - b1) * t)
			return string.format("#%02x%02x%02x", r, g, b)
		end

		-- Cyan to Magenta gradient (original colors from previous config)
		local start_color = "#00FFFF" -- Cyan (top-left)
		local end_color = "#FF00FF" -- Magenta (bottom-right)

		-- Read header from file
		local header_path = vim.fn.stdpath("config") .. "/ascii_header.txt"
		local header_lines = {}
		local file = io.open(header_path, "r")
		if file then
			for line in file:lines() do
				table.insert(header_lines, line)
			end
			file:close()
		end

		-- Set header with diagonal gradient (top-left to bottom-right)
		dashboard.section.header.val = header_lines
		local num_lines = #header_lines
		local max_width = 0

		-- Find the maximum width
		for _, line in ipairs(header_lines) do
			max_width = math.max(max_width, #line)
		end

		local highlights = {}

		-- Generate highlight groups and calculate positions
		for row = 1, num_lines do
			local line_highlights = {}
			for col = 1, #header_lines[row] do
				-- Calculate diagonal gradient position (0 to 1)
				local row_progress = (row - 1) / (num_lines - 1)
				local col_progress = (col - 1) / (max_width - 1)
				local t = (row_progress + col_progress) / 2
				local color = lerp_color(start_color, end_color, t)
				local hl_name = string.format("AlphaGrad_%d_%d", row, col)

				-- Create the highlight group
				vim.cmd(string.format("hi %s guifg=%s", hl_name, color))

				-- Add to line highlights
				table.insert(line_highlights, { hl_name, col - 1, col })
			end
			table.insert(highlights, line_highlights)
		end

		dashboard.section.header.opts.hl = highlights

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", ":ene<CR>"),
			dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
			dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
			dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
			dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
			dashboard.button("q", "  Quit", ":qa<CR>"),
		}

		-- Set footer
		local function footer()
			local total_plugins = #vim.tbl_keys(require("lazy").plugins())
			return "   Loaded " .. total_plugins .. " plugins"
		end

		dashboard.section.footer.val = footer()

		-- Disable alpha redraw on resize to prevent buffer errors
		dashboard.opts.opts = {
			noautocmd = true,
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Open Alpha and nvim-tree when starting without a file
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				-- Check if no files were opened
				if vim.fn.argc() == 0 then
					-- Open Alpha first
					require("alpha").start(true)
					-- Then open nvim-tree
					vim.schedule(function()
						require("nvim-tree.api").tree.open()
						-- Focus back on Alpha window
						vim.cmd("wincmd p")
					end)
				end
			end,
		})

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])

		-- Custom quit behavior when nvim-tree is open
		-- When tree is visible and user quits, show alpha welcome screen instead
		_G.smart_quit = function(force)
			local tree_visible = require("nvim-tree.view").is_visible()

			-- Only apply custom behavior if nvim-tree is open
			if not tree_visible then
				return force and "quit!" or "quit"
			end

			local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype

			-- Don't intercept quit in special buffers
			if ft == "NvimTree" or ft == "alpha" then
				return force and "quit!" or "quit"
			end

			-- Show alpha instead of quitting
			vim.schedule(function()
				require("alpha").start(false)
			end)

			-- Return empty string to cancel the quit command
			return ""
		end

		-- Intercept <CR> in command mode to handle :q and :q!
		vim.keymap.set('c', '<CR>', function()
			local cmd = vim.fn.getcmdline()
			if vim.fn.getcmdtype() == ':' then
				if cmd == 'q' then
					-- Clear command line and exit command mode
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, true, true), 'n', false)
					vim.schedule(function()
						local result = _G.smart_quit(0)
						if result ~= "" then
							vim.cmd(result)
						end
					end)
					return ''
				elseif cmd == 'q!' then
					-- Clear command line and exit command mode
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, true, true), 'n', false)
					vim.schedule(function()
						local result = _G.smart_quit(1)
						if result ~= "" then
							vim.cmd(result)
						end
					end)
					return ''
				end
			end
			-- Normal Enter behavior for everything else
			return vim.api.nvim_replace_termcodes('<CR>', true, true, true)
		end, { expr = true })

	end,
}
