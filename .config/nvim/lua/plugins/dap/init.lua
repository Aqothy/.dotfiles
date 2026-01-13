return {
    {
        "mfussenegger/nvim-dap",
        keys = {
            {
                "<leader>dq",
                function()
                    require("dap").list_breakpoints()
                    vim.cmd("copen")
                end,
                desc = "List Breakpoints",
            },
        },
        config = function()
            local dap = require("dap")

            local icons = require("config.icons").dap

            for name, sign in pairs(icons) do
                sign = type(sign) == "table" and sign or { sign }
                vim.fn.sign_define("Dap" .. name, {
                    text = sign[1] --[[@as string]],
                    texthl = sign[2] or "DiagnosticInfo",
                    linehl = sign[3],
                    numhl = sign[3],
                })
            end

            local settings = require("plugins.dap.dap-settings")

            for adapter_name, opts in pairs(settings) do
                if opts.enabled ~= false then
                    dap.adapters[adapter_name] = opts.adapter

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
                "<leader>dm",
                function()
                    require("debugmaster").mode.toggle()
                end,
                desc = "Toggle DebugMaster",
            },
        },
    },
}
