local command = vim.api.nvim_create_user_command

command("SI", function(opts)
    local size = tonumber(opts.args)

    if not size then
        vim.notify("Please provide a number for indent size", vim.log.levels.ERROR)
        return
    end

    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = size
    vim.opt_local.tabstop = size
    vim.opt_local.softtabstop = size

    vim.notify(string.format("Set indent to %d for current buffer", size), vim.log.levels.INFO)
end, {
    nargs = 1,
    desc = "Set indent options for the current buffer",
})
