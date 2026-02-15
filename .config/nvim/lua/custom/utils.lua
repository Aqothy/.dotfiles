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
    if not cmd or cmd == "" then
        return vim.notify("No command provided", vim.log.levels.ERROR)
    end

    opts = opts or {}
    local lines = {}

    local function on_event(_, data)
        if data then
            for _, line in ipairs(data) do
                if line ~= "" then
                    table.insert(lines, line)
                end
            end
        end
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

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = on_event,
        on_stderr = on_event,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if not opts.bang then
                    if not efm or efm == "" then
                        efm = vim.api.nvim_get_option_value("errorformat", { scope = "global" })
                    end

                    vim.fn.setqflist({}, "r", {
                        title = title,
                        lines = lines,
                        efm = efm,
                    })

                    vim.cmd("copen")
                end

                local is_success = exit_code == 0
                if not opts.bang or not is_success then
                    local msg = title .. (is_success and ": Success" or ": Failed")
                    local level = is_success and vim.log.levels.INFO or vim.log.levels.ERROR
                    vim.notify(msg, level)
                end

                if is_success then
                    run_callback(opts.on_success, lines)
                else
                    run_callback(opts.on_failure, lines)
                end

                run_callback(opts.on_exit, exit_code, lines)
            end)
        end,
    })
end

return M
