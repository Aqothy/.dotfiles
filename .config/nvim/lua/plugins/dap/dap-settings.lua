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

M["pwa-node"] = {
    filetypes = { "typescript", "javascript" },
    adapter = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = "node",
            args = {
                vim.fn.expand("~/.local/bin/dapDebugServer.js"),
                "${port}",
            },
        },
    },
    configurations = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = dap_utils.pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
        },
        {
            name = "Debug via tsx",
            type = "pwa-node",
            request = "launch",
            program = "${file}",
            runtimeExecutable = "tsx",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
        },
    },
}

M["node"] = {
    adapter = function(callback, config)
        if config.type == "node" then
            config.type = "pwa-node"
        end
        local nativeAdapter = M["pwa-node"].adapter
        if type(nativeAdapter) == "function" then
            nativeAdapter(callback, config)
        else
            callback(nativeAdapter)
        end
    end,
}

return M
