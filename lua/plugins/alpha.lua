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

		-- Custom quit function when nvim-tree is open
		_G.smart_quit = function(force)
			-- Convert 0/1 to proper boolean (Lua treats 0 as truthy!)
			force = (force ~= 0)
			print("DEBUG: smart_quit called with force=" .. tostring(force))

			local tree_visible = require("nvim-tree.view").is_visible()
			print("DEBUG: tree_visible=" .. tostring(tree_visible))

			-- Only apply custom behavior if nvim-tree is open
			if not tree_visible then
				print("DEBUG: Tree not visible, returning normal quit")
				return force and "quit!" or "quit"
			end

			local current_buf = vim.api.nvim_get_current_buf()
			local ft = vim.bo[current_buf].filetype
			print("DEBUG: current_buf=" .. current_buf .. ", filetype=" .. ft)

			-- Don't intercept if we're in nvim-tree or alpha
			if ft == "NvimTree" or ft == "alpha" then
				print("DEBUG: In special buffer, returning normal quit")
				return force and "quit!" or "quit"
			end

			-- Check if buffer has unsaved changes
			local function has_unsaved_changes(buf)
				-- DEBUG: Print buffer info
				local bufname = vim.api.nvim_buf_get_name(buf)
				local modified = vim.bo[buf].modified
				local readable = vim.fn.filereadable(bufname)
				local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				local line_count = #lines
				local first_line = lines[1] or ""

				print(string.format("DEBUG: buf=%d, name='%s', modified=%s, readable=%d, lines=%d, first='%s'",
					buf, bufname, tostring(modified), readable, line_count, first_line))

				-- Standard modified flag
				if vim.bo[buf].modified then
					print("DEBUG: Returning true - modified flag set")
					return true
				end

				-- Check for buffers that don't exist on disk yet (unnamed or new files)
				if bufname == "" or vim.fn.filereadable(bufname) == 0 then
					-- File doesn't exist on disk - check if it has any content
					-- If it has more than one line, or the first line isn't empty, it has content
					if #lines > 1 or (#lines == 1 and lines[1] ~= "") then
						print("DEBUG: Returning true - new file with content")
						return true
					end
				end

				print("DEBUG: Returning false - no unsaved changes detected")
				return false
			end

			-- Get all listed buffers (excluding special buffers and current)
			local buffers = vim.tbl_filter(function(buf)
				return vim.api.nvim_buf_is_valid(buf)
					and vim.bo[buf].buflisted
					and vim.bo[buf].buftype == ""
					and buf ~= current_buf
			end, vim.api.nvim_list_bufs())

			print("DEBUG: Found " .. #buffers .. " other buffers")

			if #buffers > 0 then
				print("DEBUG: Multiple buffers case - checking current buffer for changes")
				-- Multiple buffers - check for unsaved changes BEFORE switching
				if not force and has_unsaved_changes(current_buf) then
					-- Has unsaved changes and not forced - show error, don't switch
					vim.api.nvim_err_writeln("E37: No write since last change (add ! to override)")
					return ""
				else
					-- Either forced or no unsaved changes - switch and delete
					if force then
						return "bp | bd! #"
					else
						return "bp | bd #"
					end
				end
			else
				print("DEBUG: Last buffer case")
				-- No other buffers - last buffer case
				if force then
					print("DEBUG: Force delete last buffer")
					-- :q! - force delete and show Alpha
					vim.schedule(function()
						vim.cmd("bdelete!")
						require("alpha").start(true)
					end)
					return ""
				else
					print("DEBUG: Normal quit on last buffer - checking for changes")
					-- :q - only delete if no unsaved changes, otherwise error
					if has_unsaved_changes(current_buf) then
						print("DEBUG: Last buffer has unsaved changes")
						-- Show the standard Vim error
						vim.api.nvim_err_writeln("E37: No write since last change (add ! to override)")
						return ""
					else
						-- No unsaved changes, safe to delete and show Alpha
						vim.schedule(function()
							vim.cmd("bdelete")
							require("alpha").start(true)
						end)
						return ""
					end
				end
			end
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

		-- Also handle :bd (buffer delete) when nvim-tree is open
		vim.api.nvim_create_autocmd("BufDelete", {
			callback = function(args)
				-- Only apply custom behavior if nvim-tree is open
				if not require("nvim-tree.view").is_visible() then
					return
				end

				-- Check if the deleted buffer is a normal file buffer
				if vim.bo[args.buf].buftype ~= "" then
					return
				end

				vim.schedule(function()
					-- Count normal windows
					local normal_windows = vim.tbl_filter(function(win)
						local buf = vim.api.nvim_win_get_buf(win)
						local ft = vim.bo[buf].filetype
						return ft ~= "NvimTree" and ft ~= "alpha"
					end, vim.api.nvim_list_wins())

					-- Get remaining buffers
					local buffers = vim.tbl_filter(function(buf)
						return vim.api.nvim_buf_is_valid(buf)
							and vim.bo[buf].buflisted
							and vim.bo[buf].buftype == ""
							and buf ~= args.buf
					end, vim.api.nvim_list_bufs())

					-- If we have a normal window open but no buffers, show alpha
					if #normal_windows > 0 and #buffers == 0 then
						require("alpha").start(true)
					end
				end)
			end,
		})
	end,
}
