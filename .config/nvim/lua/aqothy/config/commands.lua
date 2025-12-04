local utils = require("aqothy.config.utils")

local command = vim.api.nvim_create_user_command

local get_option = vim.api.nvim_get_option_value

command("Make", function(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local cmd = ""
    local global_makeprg = get_option("makeprg", { scope = "global" })
    local efm = get_option("errorformat", { buf = bufnr })
    local no_qf = false

    if opts.args and opts.args ~= "" then
        local args = vim.fn.expandcmd(opts.args)
        cmd = global_makeprg .. " " .. args
        no_qf = true
    else
        local local_makeprg = get_option("makeprg", { buf = bufnr })

        if local_makeprg ~= "" then
            cmd = vim.fn.expandcmd(local_makeprg)
        else
            cmd = vim.fn.expandcmd(global_makeprg)
            no_qf = true
        end
    end

    utils.run_async(cmd, efm, cmd, { no_qf = no_qf })
end, { nargs = "*", complete = "file", desc = "Async Make" })

command("R", function(opts)
    local cmd = vim.fn.expandcmd(opts.args)

    utils.run_async(cmd, nil, cmd, { no_qf = true })
end, { nargs = "+", complete = "shellcmdline", desc = "Run commands" })

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

    utils.run_async(cmd, efm, "Grep")
end, { nargs = "+", complete = "file", desc = "Async Grep" })

command("Tsc", function()
    local cmd = "npx tsgo --noEmit"
    local efm = "%f %#(%l\\,%c): %trror TS%n: %m,%trror TS%n: %m,%-G%.%#"

    utils.run_async(cmd, efm, "Tsc")
end, { nargs = 0, desc = "Run TSC" })

command("GoLint", function()
    local cmd = "golangci-lint run"
    local efm = "%A%f:%l:%c: %m,%-G%.%#"

    utils.run_async(cmd, efm, "GolangCI-Lint")
end, { nargs = 0, desc = "Run GolangCI-Lint" })
