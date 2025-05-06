return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"williamboman/mason.nvim",
		},
		-- stylua: ignore
		keys = {
			{
				"<leader>wt",
				function() local widgets = require("dap.ui.widgets") widgets.centered_float(widgets.threads) end,
				desc = "Show threads in float",
			},
			{
				"<leader>ss",
				function() local widgets = require("dap.ui.widgets") widgets.sidebar(widgets.scopes).open() end,
				desc = "Show scopes in sidebar",
			},
			{ "<leader>wh", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
			{
				"<leader>wp",
				function() local widgets = require("dap.ui.widgets") widgets.preview(nil, { listener = { "event_stopped" } }) end,
				desc = "Preview",
				mode = { "n", "v" },
			},
			{
				"<leader>ri",
				function() require("dap").repl.open() require("dap").repl.execute(vim.fn.expand("<cexpr>")) end,
				desc = "Inspect in REPL",
			},
			{
				"<leader>ri",
				function() local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v")) require("dap").repl.open() require("dap").repl.execute(table.concat(lines, "\n")) end,
				desc = "Execute selection in REPL",
				mode = "x",
			},
			{ "<leader>rt", function () require("dap").repl.toggle({ height = 12 }) end, desc = "Toggle DAP UI" },
			{
				"<leader>cp",
				function()
					require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: '))
				end,
				desc = "Breakpoint Condition"
			},
			{ "<leader>bp", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
			{ "<leader>cp", function() require("dap").continue() end, desc = "Run/Continue" },
			{ "<leader>si", function() require("dap").step_into() end, desc = "Step Into" },
			{ "<leader>sO", function() require("dap").step_out() end, desc = "Step Out" },
			{ "<leader>so", function() require("dap").step_over() end, desc = "Step Over" },
			{ "<leader>eb", function() require("dap").terminate({ hierarchy = true }) end, desc = "Terminate" },
			{ "<leader>rl", function() require("dap").run_last() end, desc = "Run Last" },
			{ "<leader>cb", function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoint" },
			{ "<leader>tl", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
			{ "<leader>rs", function () require("dap").restart() end, desc = "Restart" },
			{ "<leader>rr", function () require("dap").reload() end, desc = "Reload" },
			{ "<leader>lb", function () require("dap").list_breakpoints(true) end, desc = "List Breakpoints" },
		},
		config = function()
			local dap = require("dap")
			local icons = require("aqothy.config.user").dap

			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			for name, sign in pairs(icons) do
				sign = type(sign) == "table" and sign or { sign }
				vim.fn.sign_define("Dap" .. name, {
					text = sign[1] --[[@as string]],
					texthl = sign[2] or "DiagnosticInfo",
					linehl = sign[3],
					numhl = sign[3],
				})
			end

			local settings = require("aqothy.config.dap-settings")

			for adapter_name, opts in pairs(settings) do
				if opts.enabled ~= false then
					dap.adapters[adapter_name] = opts.adapter

					-- Set up configurations for associated filetypes
					for _, ft in ipairs(opts.filetypes or {}) do
						dap.configurations[ft] = opts.configurations
					end
				end
			end
		end,
	},
}
