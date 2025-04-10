local M = {}

local dap_utils = require("dap.utils")

M["delve"] = {
	enabled = true,
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
					args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
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
		{
			type = "delve",
			name = "Debug test (go.mod)",
			request = "launch",
			mode = "test",
			program = "./${relativeFileDirname}",
		},
	},
}

M["pwa-node"] = {
	enabled = true,
	filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
	adapter = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "node",
			args = {
				vim.fn.stdpath("data") .. "/mason" .. "/packages/" .. "js-debug-adapter/js-debug/src/dapDebugServer.js",
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
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach",
			processId = dap_utils.pick_process,
			cwd = "${workspaceFolder}",
		},
	},
}

M["codelldb"] = {
	enabled = true,
	filetypes = { "c", "cpp" },
	adapter = {
		type = "server",
		host = "127.0.0.1",
		port = "${port}",
		executable = {
			command = "codelldb",
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
			name = "Launch file",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
		},
		{
			type = "codelldb",
			request = "attach",
			name = "Attach to process",
			pid = dap_utils.pick_process,
			cwd = "${workspaceFolder}",
		},
	},
}

return M
