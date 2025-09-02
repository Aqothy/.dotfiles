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

            local settings = require("aqothy.config.dap-settings")

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
                "<leader>D",
                function()
                    require("debugmaster").mode.toggle()
                end,
                desc = "Toggle DebugMaster",
            },
        },
    },
}
