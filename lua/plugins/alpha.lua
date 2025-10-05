-- WARNING: DO NOT AUTOFORMAT THIS FILE
-- stylua will fuck this file royally.
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
		local quit_button_index = nil
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
						vim.api.nvim_echo({ { err, "ErrorMsg" } }, true, {})
					end
				end
				quit_button_index = i
				break
			end
		end

		-- Add force quit button after the quit button (no shortcut key)
		if quit_button_index then
			-- Add padding before force quit button
			local padding1 = { type = "padding", val = 1 }
			local padding2 = { type = "padding", val = 1 }
			local padding3 = { type = "padding", val = 1 }

			local force_quit_button = {
				type = "button",
				val = "󰗼  Force Quit",
				on_press = function()
					-- Create floating window confirmation popup
					local width = 50
					local height = 7
					local buf = vim.api.nvim_create_buf(false, true)

					-- Center the window
					local ui = vim.api.nvim_list_uis()[1]
					local win_width = ui.width
					local win_height = ui.height
					local row = math.floor((win_height - height) / 2)
					local col = math.floor((win_width - width) / 2)

					local opts = {
						relative = "editor",
						width = width,
						height = height,
						row = row,
						col = col,
						style = "minimal",
						border = "rounded",
						title = " Force Quit Confirmation ",
						title_pos = "center",
					}

					local win = vim.api.nvim_open_win(buf, true, opts)

					-- Set buffer content
					local lines = {
						"",
						"  Are you sure you want to force quit?",
						"  This will discard all unsaved changes!",
						"",
						"    [N] No (default)      [Y] Yes",
						"",
					}
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

					-- Set highlighting
					vim.api.nvim_buf_add_highlight(buf, 0, "WarningMsg", 1, 0, -1)
					vim.api.nvim_buf_add_highlight(buf, 0, "ErrorMsg", 2, 0, -1)
					vim.api.nvim_buf_add_highlight(buf, 0, "Special", 4, 4, 19)
					vim.api.nvim_buf_add_highlight(buf, 0, "Keyword", 4, 26, 33)

					-- Set buffer options
					vim.api.nvim_buf_set_option(buf, "modifiable", false)
					vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

					-- Cursor navigation state
					local selected = 1 -- 1 = No, 2 = Yes
					local no_col = 5 -- Position of 'N' in "[N] No"
					local yes_col = 27 -- Position of 'Y' in "[Y] Yes"

					local function update_cursor()
						if selected == 1 then
							vim.api.nvim_win_set_cursor(win, { 5, no_col })
							-- Highlight No option
							vim.api.nvim_buf_clear_namespace(buf, 1, 0, -1)
							vim.api.nvim_buf_add_highlight(buf, 1, "Visual", 4, 4, 19)
						else
							vim.api.nvim_win_set_cursor(win, { 5, yes_col })
							-- Highlight Yes option
							vim.api.nvim_buf_clear_namespace(buf, 1, 0, -1)
							vim.api.nvim_buf_add_highlight(buf, 1, "Visual", 4, 26, 33)
						end
					end

					-- Key mappings for the popup
					local function close_and_quit()
						vim.api.nvim_win_close(win, true)
						if require("nvim-tree.view").is_visible() then
							require("nvim-tree.api").tree.close()
						end
						vim.cmd("qa!")
					end

					local function close_popup()
						vim.api.nvim_win_close(win, true)
					end

					local function select_no()
						selected = 1
						update_cursor()
					end

					local function select_yes()
						selected = 2
						update_cursor()
					end

					local function confirm_selection()
						if selected == 2 then
							close_and_quit()
						else
							close_popup()
						end
					end

					-- Map keys in the popup buffer
					vim.keymap.set("n", "h", select_no, { buffer = buf, nowait = true })
					vim.keymap.set("n", "<Left>", select_no, { buffer = buf, nowait = true })
					vim.keymap.set("n", "l", select_yes, { buffer = buf, nowait = true })
					vim.keymap.set("n", "<Right>", select_yes, { buffer = buf, nowait = true })
					vim.keymap.set("n", "<Tab>", function()
						selected = selected == 1 and 2 or 1
						update_cursor()
					end, { buffer = buf, nowait = true })
					vim.keymap.set("n", "<S-Tab>", function()
						selected = selected == 1 and 2 or 1
						update_cursor()
					end, { buffer = buf, nowait = true })
					vim.keymap.set("n", "<CR>", confirm_selection, { buffer = buf, nowait = true })
					vim.keymap.set("n", "<Space>", confirm_selection, { buffer = buf, nowait = true })
					vim.keymap.set("n", "y", close_and_quit, { buffer = buf, nowait = true })
					vim.keymap.set("n", "Y", close_and_quit, { buffer = buf, nowait = true })
					vim.keymap.set("n", "n", close_popup, { buffer = buf, nowait = true })
					vim.keymap.set("n", "N", close_popup, { buffer = buf, nowait = true })
					vim.keymap.set("n", "<Esc>", close_popup, { buffer = buf, nowait = true })
					vim.keymap.set("n", "q", close_popup, { buffer = buf, nowait = true })

					-- Set initial cursor position and highlight
					update_cursor()
				end,
				opts = {
					position = "left",
					shortcut = "",
					cursor = 3,
					width = 50,
					align_shortcut = "right",
					hl_shortcut = "Keyword",
				},
			}
			table.insert(dashboard.section.bottom_buttons.val, quit_button_index + 1, padding1)
			table.insert(dashboard.section.bottom_buttons.val, quit_button_index + 2, padding2)
			table.insert(dashboard.section.bottom_buttons.val, quit_button_index + 3, padding3)
			table.insert(dashboard.section.bottom_buttons.val, quit_button_index + 4, force_quit_button)
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
							vim.api.nvim_echo({ { err, "ErrorMsg" } }, true, {})
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
