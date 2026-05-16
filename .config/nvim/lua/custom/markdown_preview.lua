local M = {}

local opts = {
    host = "localhost",
    port = 3333,
    auto_open = true,
    auto_close = true,
}

local previews = {}
local group = vim.api.nvim_create_augroup("markdown_preview", { clear = true })

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Markdown Preview" })
end

local function running(preview)
    return preview and vim.fn.jobwait({ preview.job }, 0)[1] == -1
end

local function next_port()
    local used = {}
    for _, preview in pairs(previews) do
        used[preview.port] = true
    end

    local port = opts.port
    while used[port] do
        port = port + 1
    end
    return port
end

function M.stop(buf)
    buf = buf or vim.api.nvim_get_current_buf()

    local preview = previews[buf]
    if running(preview) then
        vim.fn.jobstop(preview.job)
        notify("Stopped preview")
    end

    previews[buf] = nil
    vim.api.nvim_clear_autocmds({ group = group, buf = buf })
end

function M.toggle()
    local buf = vim.api.nvim_get_current_buf()
    if running(previews[buf]) then
        return M.stop(buf)
    end

    if vim.fn.executable("gh") ~= 1 then
        return notify("gh cli not installed", vim.log.levels.ERROR)
    end

    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" then
        return notify("Save the file first", vim.log.levels.ERROR)
    end
    if vim.bo[buf].modified then
        vim.cmd.write()
    end

    local port = next_port()
    local cmd = { "gh", "markdown-preview", file, "--host", opts.host, "--port", tostring(port) }
    if not opts.auto_open then
        cmd[#cmd + 1] = "--disable-auto-open"
    end

    local job = vim.fn.jobstart(cmd, {
        cwd = vim.fn.fnamemodify(file, ":h"),
        on_exit = vim.schedule_wrap(function(exited_job, code)
            local preview = previews[buf]
            if preview and preview.job == exited_job then
                previews[buf] = nil
                vim.api.nvim_clear_autocmds({ group = group, buf = buf })
            end
            if code ~= 0 and code ~= 143 then
                notify("Preview exited with code " .. code, vim.log.levels.ERROR)
            end
        end),
    })

    if job <= 0 then
        return notify("Failed to start gh markdown-preview", vim.log.levels.ERROR)
    end

    previews[buf] = { job = job, port = port }
    if opts.auto_close then
        vim.api.nvim_create_autocmd("BufHidden", {
            group = group,
            buf = buf,
            callback = function()
                M.stop(buf)
            end,
        })
    end

    notify("Previewing at http://" .. opts.host .. ":" .. port)
end

function M.setup(config)
    opts = vim.tbl_extend("force", opts, config or {})
end

return M
