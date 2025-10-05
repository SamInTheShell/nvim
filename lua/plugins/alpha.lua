return {
	"goolord/alpha-nvim",
	-- dependencies = { 'echasnovski/mini.icons' },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local dashboard = require("alpha.themes.startify")
		dashboard.file_icons.provider = "devicons"

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

		-- Read ASCII art from external file
		local header_file = vim.fn.stdpath("config") .. "/ascii_header.txt"
		local header_lines = {}

		local file = io.open(header_file, "r")
		if file then
			for line in file:lines() do
				table.insert(header_lines, line)
			end
			file:close()
		else
			-- Fallback header if file doesn't exist
			header_lines = { "nvim" }
		end

		dashboard.section.header.val = header_lines

		-- Create gradient highlight groups and mapping
		local start_color = "#00FFFF" -- Cyan (top-left)
		local end_color = "#FF00FF" -- Magenta (bottom-right)
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

		-- Filter MRU to only show files from current directory
		local cwd = vim.fn.getcwd()
		dashboard.section.mru.val = {
			-- {
			--   type = "text",
			--   val = "Recent files",
			--   opts = { hl = "SpecialComment", shrink_margin = false, position = "center" },
			-- },
			-- { type = "padding", val = 1 },
			-- {
			--   type = "group",
			--   val = function()
			--     return { dashboard.mru(0, cwd) }
			--   end,
			--   opts = { shrink_margin = false },
			-- },
		}

		-- Override the quit button's keymap and on_press to close nvim-tree first then quit
		-- Find and fix the quit button (usually the last button)
		for i, button in ipairs(dashboard.section.bottom_buttons.val) do
			if button.val and (string.match(button.val:lower(), "quit") or string.match(button.val:lower(), "q")) then
				local quit_command =
					"<cmd>lua if require('nvim-tree.view').is_visible() then require('nvim-tree.api').tree.close() end; local ok, err = pcall(vim.cmd, 'qa'); if not ok then vim.api.nvim_echo({{ err, 'ErrorMsg' }}, true, {}) end<CR>"
				button.opts.keymap[3] = quit_command
				-- Override on_press to execute the same command as the keymap
				button.on_press = function()
					if require("nvim-tree.view").is_visible() then
						require("nvim-tree.api").tree.close()
					end
					-- Use pcall to catch errors and display them properly
					local ok, err = pcall(vim.cmd, "qa")
					if not ok then
						-- Re-display the error message that Vim would normally show
						vim.api.nvim_echo({{ err, "ErrorMsg" }}, true, {})
					end
				end
				break
			end
		end

		require("alpha").setup(dashboard.config)

		-- Remap :q and :q! to work properly when alpha buffer is in focus
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "alpha",
			callback = function(args)
				-- Override Enter key but only for q and q! commands, let everything else through
				vim.keymap.set("c", "<CR>", function()
					local cmdline = vim.fn.getcmdline()
					if cmdline == "q" then
						-- Clear command line and execute our custom quit with proper error handling
						vim.api.nvim_feedkeys(
							vim.api.nvim_replace_termcodes("<C-u><Esc>", true, false, true),
							"n",
							false
						)
						if require("nvim-tree.view").is_visible() then
							require("nvim-tree.api").tree.close()
						end
						-- Use pcall to catch errors and display them properly
						local ok, err = pcall(vim.cmd, "qa")
						if not ok then
							-- Re-display the error message that Vim would normally show
							vim.api.nvim_echo({{ err, "ErrorMsg" }}, true, {})
						end
					elseif cmdline == "q!" then
						-- Clear command line and execute our custom force quit
						vim.api.nvim_feedkeys(
							vim.api.nvim_replace_termcodes("<C-u><Esc>", true, false, true),
							"n",
							false
						)
						if require("nvim-tree.view").is_visible() then
							require("nvim-tree.api").tree.close()
						end
						vim.cmd("qa!")
					else
						-- For all other commands, execute normally
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
					end
				end, { buffer = args.buf })
			end,
		})
	end,
}
