local M = {}

local dap_utils = require("dap.utils")
local share = vim.fs.dirname(vim.fn.stdpath("data"))

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
            name = "Launch",
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
                share .. "/js-debug/src/dapDebugServer.js",
                "${port}",
            },
        },
    },
    configurations = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch",
            program = "${file}",
            runtimeExecutable = function()
                local ft = vim.bo.filetype
                if ft == "typescript" then
                    return "tsx"
                end
            end,
            cwd = "${workspaceFolder}",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            console = "integratedTerminal",
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = dap_utils.pick_process,
            cwd = "${workspaceFolder}",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
    },
}

-- vscode dap config uses node, convert to pwa-node
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

M["codelldb"] = {
    filetypes = { "c", "cpp", "rust" },
    adapter = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = share .. "/codelldb/adapter/codelldb",
            args = {
                "--port",
                "${port}",
            },
        },
    },
    configurations = {
        {
            type = "codelldb",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
        },
        {
            type = "codelldb",
            request = "attach",
            name = "Attach",
            pid = dap_utils.pick_process,
            cwd = "${workspaceFolder}",
        },
    },
}

return M
