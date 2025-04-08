return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"williamboman/mason.nvim",
		},
    -- stylua: ignore
    keys = {
        {
            "<leader>bc",
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
        { "<leader>eb", function() require("dap").terminate() end, desc = "Terminate" },
        { "<leader>rt", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
        { "<leader>wh", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
        { "<leader>rl", function() require("dap").run_last() end, desc = "Run Last" },
        { "<leader>cb", function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoint" },
        { "<leader>tl", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
        {
            "<leader>sf",
            function()
                local my_sidebar = widgets.sidebar(widgets.frames)
                my_sidebar.open()
            end,
            desc = "Frames"
        },
        {
            "<leader>vs",
            function()
                local widgets = require('dap.ui.widgets')
                local my_sidebar = widgets.sidebar(widgets.scopes)
                my_sidebar.open()
            end,
            desc = "Scopes"
        },
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
}
