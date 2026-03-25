local M = {}

local function run_callback(title, cb, ...)
    if type(cb) ~= "function" then
        return
    end

    local ok, err = pcall(cb, ...)
    if not ok then
        vim.notify(title .. ": callback failed: " .. err, vim.log.levels.ERROR)
    end
end

function M.spawn(cmd, opts)
    if not cmd or (type(cmd) == "string" and cmd == "") then
        return vim.notify("No command provided", vim.log.levels.ERROR)
    end

    opts = opts or {}
    local title = opts.title or (type(cmd) == "string" and cmd or "Process")
    local efm = opts.efm

    if not efm or efm == "" then
        efm = vim.api.nvim_get_option_value("errorformat", { scope = "global" })
    end

    local stream_buf = {
        stdout = "",
        stderr = "",
    }

    vim.fn.setqflist({}, " ", { title = title, lines = {}, efm = efm })
    local qf_id = vim.fn.getqflist({ id = 0 }).id

    local function append_lines(lines)
        if #lines == 0 then
            return
        end

        vim.fn.setqflist({}, "a", { id = qf_id, title = title, lines = lines, efm = efm })
    end

    local function handle_output(stream, data)
        if type(data) ~= "table" or #data == 0 then
            return
        end

        data[1] = stream_buf[stream] .. (data[1] or "")
        stream_buf[stream] = data[#data] or ""
        table.remove(data, #data)

        append_lines(data)
    end

    local job_id = vim.fn.jobstart(cmd, {
        on_stdout = vim.schedule_wrap(function(_, data)
            handle_output("stdout", data)
        end),
        on_stderr = vim.schedule_wrap(function(_, data)
            handle_output("stderr", data)
        end),
        on_exit = function(_, code)
            vim.schedule(function()
                if stream_buf.stdout ~= "" then
                    append_lines({ stream_buf.stdout })
                end

                if stream_buf.stderr ~= "" then
                    append_lines({ stream_buf.stderr })
                end

                local result = { code = code }
                local is_success = code == 0

                vim.notify(
                    title .. (is_success and ": Success" or ": Failed"),
                    is_success and vim.log.levels.INFO or vim.log.levels.ERROR
                )

                if not opts.bang then
                    vim.cmd("cwindow")
                end

                vim.cmd("checktime")

                if is_success and opts.on_success then
                    run_callback(title, opts.on_success, result)
                elseif not is_success and opts.on_failure then
                    run_callback(title, opts.on_failure, result)
                end

                run_callback(title, opts.on_exit, result)
            end)
        end,
    })

    if job_id <= 0 then
        vim.notify("Failed to start process: " .. title, vim.log.levels.ERROR)
        local result = { code = -1 }

        run_callback(title, opts.on_failure, result)
        run_callback(title, opts.on_exit, result)
    elseif not opts.bang then
        vim.cmd("copen | wincmd p")
    end

    return job_id
end

function M.run(cmd, opts)
    if not cmd or (type(cmd) == "string" and cmd == "") then
        return vim.notify("No command provided", vim.log.levels.ERROR)
    end

    opts = opts or {}
    local title = opts.title or (type(cmd) == "string" and cmd or "Process")

    if type(cmd) == "string" then
        cmd = { vim.o.shell, vim.o.shellcmdflag, cmd }
    end

    return vim.system(cmd, {
        text = true,
        cwd = opts.cwd,
        env = opts.env,
    }, function(obj)
        vim.schedule(function()
            local result = {
                code = obj.code,
                signal = obj.signal,
                stdout = obj.stdout or "",
                stderr = obj.stderr or "",
            }
            local is_success = result.code == 0

            vim.cmd("checktime")

            if is_success then
                run_callback(title, opts.on_success, result)
            else
                run_callback(title, opts.on_failure, result)
            end

            run_callback(title, opts.on_exit, result)
        end)
    end)
end

return M
