return {
    {
        "mfussenegger/nvim-dap",
        -- stylua: ignore
        keys = {
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
            { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
            { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
            { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
            { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
            { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
            { "<leader>dq", function() require("dap").list_breakpoints() end, desc = "List Breakpoints" },
            { "<leader>ds", function()
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.scopes)
            end, desc = "Dap Scopes" },
            { "<leader>df", function()
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.frames)
            end, desc = "Dap Frames" },
        },
        config = function()
            local dap = require("dap")
            local icons = require("aqothy.config.icons").dap

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
