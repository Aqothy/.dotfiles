local utils = require("custom.utils")

local command = vim.api.nvim_create_user_command

local get_option = vim.api.nvim_get_option_value

if vim.g.vscode then
    return
end

command("Make", function(opts)
    local buf = vim.api.nvim_get_current_buf()
    local efm = get_option("errorformat", { buf = buf })
    local cmd = get_option("makeprg", { buf = buf })

    if cmd == "" then
        cmd = get_option("makeprg", { scope = "global" })
    end

    cmd = vim.fn.expandcmd(cmd)
    local args = opts.args ~= "" and vim.fn.expandcmd(opts.args) or ""

    if args ~= "" then
        cmd = cmd .. " " .. args
    end

    utils.run_async(cmd, efm, cmd, { bang = opts.bang })
end, { nargs = "*", bang = true, complete = "file", desc = "Async Make" })

command("Run", function(opts)
    local cmd = vim.fn.expandcmd(opts.args)

    utils.run_async(cmd, nil, cmd, { bang = opts.bang })
end, { nargs = "+", bang = true, complete = "shellcmdline", desc = "Run async shell command" })

command("Tsc", function(opts)
    local cmd = "npx tsgo --noEmit"
    local efm = "%f %#(%l\\,%c): %trror TS%n: %m,%trror TS%n: %m,%-G%.%#"

    utils.run_async(cmd, efm, "Tsc", { bang = opts.bang })
end, { nargs = 0, bang = true, desc = "Run TSC" })

command("GoLint", function(opts)
    local cmd = "golangci-lint run"
    local efm = "%A%f:%l:%c: %m,%-G%.%#"

    utils.run_async(cmd, efm, "GolangCI-Lint", { bang = opts.bang })
end, { nargs = 0, bang = true, desc = "Run GolangCI-Lint" })

command("LspLog", function()
    vim.cmd("tabnew " .. vim.lsp.log.get_filename())
end, {
    desc = "Open lsp log",
})

command("LspDebug", function()
    vim.lsp.log.set_level(vim.log.levels.WARN)
end, { desc = "enable lsp log" })
