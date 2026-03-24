local M = {}

local dap_utils = require("dap.utils")
local share = vim.fs.dirname(vim.fn.stdpath("data"))

local function get_unused_port()
    local server = assert(vim.uv.new_tcp())
    assert(server:bind("127.0.0.1", 0))
    local port = server:getsockname().port
    server:close()
    assert(port > 0, "Failed to get unused port")
    return port
end

-- HACK: for debuggers that dont send runInTerminal req to dap, dap cant launch terminal
-- we need to launch debugger in terminal ourselves and attach dap to that terminal
-- to get terminal working, similar thing that vscode is doing
local function launch_in_terminal(command_builder, callback)
    local port = get_unused_port()
    vim.cmd("belowright 12new")

    local cmd = command_builder(port)
    local job_id = vim.fn.jobstart(cmd, {
        term = true,
        on_exit = function(_, code)
            if code ~= 0 then
                vim.notify("DAP terminal exited with code " .. code, vim.log.levels.ERROR)
            end
        end,
    })

    if job_id <= 0 then
        error("Failed to start DAP terminal: " .. table.concat(cmd, " "))
    end

    -- Delay connection slightly to ensure the TCP server is listening
    vim.defer_fn(function()
        callback({
            type = "server",
            host = "127.0.0.1",
            port = port,
        })
    end, 100)
end

M["delve"] = {
    filetypes = { "go" },
    adapter = function(callback, config)
        if config.mode == "remote" and config.request == "attach" then
            callback({
                type = "server",
                host = config.host or "127.0.0.1",
                port = config.port or "38697",
            })
            return
        end

        launch_in_terminal(function(port)
            return { "dlv", "dap", "-l", ("127.0.0.1:%d"):format(port) }
        end, callback)
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
