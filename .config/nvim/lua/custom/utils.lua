local M = {}

function M.bufname_valid(bufname)
    if
        bufname:match("^/")
        or bufname:match("^[a-zA-Z]:")
        or bufname:match("^zipfile://")
        or bufname:match("^tarfile:")
    then
        return true
    end
    return false
end

function M.run_async(cmd, efm, title, opts)
    if not cmd or (type(cmd) == "string" and cmd == "") then
        return vim.notify("No command provided", vim.log.levels.ERROR)
    end

    opts = opts or {}

    if type(cmd) == "string" then
        cmd = { vim.o.shell, vim.o.shellcmdflag, cmd }
    end

    local function run_callback(cb, ...)
        if type(cb) ~= "function" then
            return
        end
        local ok, err = pcall(cb, ...)
        if not ok then
            vim.notify(title .. ": callback failed: " .. err, vim.log.levels.ERROR)
        end
    end

    vim.system(cmd, { text = true }, function(obj)
        vim.schedule(function()
            local lines = {}
            for line in (obj.stdout or ""):gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end
            for line in (obj.stderr or ""):gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end

            if not efm or efm == "" then
                efm = vim.api.nvim_get_option_value("errorformat", { scope = "global" })
            end

            vim.fn.setqflist({}, "r", { title = title, lines = lines, efm = efm })

            if not opts.bang then
                vim.cmd("cwindow")
            end

            local is_success = obj.code == 0
            local msg = title .. (is_success and ": Success" or ": Failed")
            vim.notify(msg, is_success and vim.log.levels.INFO or vim.log.levels.ERROR)

            if is_success then
                run_callback(opts.on_success, obj)
            else
                run_callback(opts.on_failure, obj)
            end
            run_callback(opts.on_exit, obj)
        end)
    end)
end

return M
