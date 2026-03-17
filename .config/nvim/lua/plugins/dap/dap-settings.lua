local M = {}

local dap_utils = require("dap.utils")

M["delve"] = {
    filetypes = { "go" },
    adapter = function(callback, config)
        if config.mode == "remote" and config.request == "attach" then
            callback({
                type = "server",
                host = config.host or "127.0.0.1",
                port = config.port or "38697",
            })
        else
            callback({
                type = "server",
                port = "${port}",
                executable = {
                    command = "dlv",
                    args = { "dap", "-l", "127.0.0.1:${port}" },
                    detached = vim.fn.has("win32") == 0,
                },
            })
        end
    end,
    configurations = {
        {
            type = "delve",
            name = "Debug",
            request = "launch",
            program = "${file}",
        },
        {
            type = "delve",
            name = "Attach",
            mode = "local",
            request = "attach",
            processId = dap_utils.pick_process,
        },
        {
            type = "delve",
            name = "Debug test",
            request = "launch",
            mode = "test",
            program = "${file}",
        },
    },
}

return M
