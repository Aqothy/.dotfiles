local utils = require("custom.utils")

local command = vim.api.nvim_create_user_command

local get_option = vim.api.nvim_get_option_value

if vim.g.vscode then
    return
end

command("Make", function(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local cmd = ""
    local global_makeprg = get_option("makeprg", { scope = "global" })
    local efm = get_option("errorformat", { buf = bufnr })

    if opts.args and opts.args ~= "" then
        local args = vim.fn.expandcmd(opts.args)
        cmd = global_makeprg .. " " .. args
    else
        local local_makeprg = get_option("makeprg", { buf = bufnr })

        if local_makeprg ~= "" then
            cmd = vim.fn.expandcmd(local_makeprg)
        else
            cmd = vim.fn.expandcmd(global_makeprg)
        end
    end

    utils.run_async(cmd, efm, cmd, { bang = opts.bang })
end, { nargs = "*", bang = true, complete = "file", desc = "Async Make" })

command("Grep", function(opts)
    local grepprg = get_option("grepprg", { scope = "global" })

    local args = vim.fn.expandcmd(opts.args)
    local split_args = vim.split(args, " ", { trimempty = true })
    local last_arg = split_args[#split_args]

    -- if you dont pass in a file or directory, rg won't search anything
    if vim.fn.isdirectory(last_arg) == 0 and vim.fn.filereadable(last_arg) == 0 then
        args = args .. " ."
    end

    local cmd = grepprg .. " " .. args
    local efm = get_option("grepformat", { scope = "global" })

    utils.run_async(cmd, efm, "Grep", { bang = opts.bang })
end, { nargs = "+", bang = true, complete = "file", desc = "Async Grep" })

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
