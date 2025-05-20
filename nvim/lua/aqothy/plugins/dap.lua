return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"mason-org/mason.nvim",
		},
		lazy = true,
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
	{
		"miroshQa/debugmaster.nvim",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		keys = {
			{
				"<leader>D",
				function()
					require("debugmaster").mode.toggle()
				end,
				desc = "Toggle DebugMaster",
				mode = { "n", "v" },
				nowait = true,
			},
		},
		config = function()
			vim.api.nvim_set_hl(0, "dCursor", { bg = "#cc241d" })
		end,
	},
}
