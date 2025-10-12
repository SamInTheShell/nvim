return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"mason-org/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Setup dap-ui
			dapui.setup()

			-- Auto open/close dap-ui
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- DAP signs
			vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "➡️", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "❌", texthl = "", linehl = "", numhl = "" })

			-- Key mappings
			vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<F6>", function()
				dap.terminate()
				dapui.close()
			end)
			vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
			vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>B", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Set Conditional Breakpoint" })
			vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result" })

			-- Godot DAP adapter
			dap.adapters.godot = {
				type = "server",
				host = "127.0.0.1",
				port = 6006,
			}

			-- Godot DAP configurations
			dap.configurations.gdscript = {
				{
					type = "godot",
					request = "launch",
					name = "Launch Godot Project",
					project = "${workspaceFolder}",
					launch_game_instance = true,
					launch_scene = false,
				},
				{
					type = "godot",
					request = "launch",
					name = "Launch Current Scene",
					project = "${workspaceFolder}",
					launch_game_instance = true,
					launch_scene = true,
				},
				{
					type = "godot",
					request = "attach",
					name = "Attach to Running Godot",
					project = "${workspaceFolder}",
				},
			}

			-- Setup mason-nvim-dap
			require("mason-nvim-dap").setup({
				automatic_installation = true,
				ensure_installed = {
					"python",
					"delve", -- Go
					"js", -- JavaScript/TypeScript
					"codelldb", -- Rust/C++
				},
				handlers = {},
			})
		end,
	},
}
