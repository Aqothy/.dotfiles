return {
	{
		"mfussenegger/nvim-dap",

		dependencies = {
			"rcarriga/nvim-dap-ui",
			-- virtual text for the debugger
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
		},

    -- stylua: ignore
    keys = {
      { "<leader>bc", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>bp", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>cp", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>si", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>so", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>sO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>eb", function() require("dap").terminate() end, desc = "Terminate" },
    },

		config = function()
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

			local dap = require("dap")
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

	-- fancy UI for the debugger
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "nvim-neotest/nvim-nio" },
    -- stylua: ignore
    keys = {
      { "<leader>tb", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
      { "<leader>ue", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
    },
		opts = {},
		config = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
			end
		end,
	},
}
