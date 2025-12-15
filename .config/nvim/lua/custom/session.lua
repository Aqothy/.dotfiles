local M = {}

M.options = {
    allowed_dirs = {},
    need = 1, -- Minimum number of normal buffers required to save a session
    dir = vim.fn.stdpath("state") .. "/sessions/",
}

M.root_dir = vim.fn.getcwd()

local function is_allowed()
    for _, dir in ipairs(M.options.allowed_dirs) do
        local expanded_dir = vim.fn.expand(dir)
        if string.find(M.root_dir, expanded_dir, 1, true) == 1 then
            return true
        end
    end
    return false
end

local function get_session_path()
    local filename = M.root_dir:gsub("[\\/:]+", "%%") .. ".vim"
    return M.options.dir .. filename
end

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.options, opts or {})

    if vim.fn.isdirectory(M.options.dir) == 0 then
        vim.fn.mkdir(M.options.dir, "p")
    end

    local arg = vim.fn.argv(0)
    ---@cast arg string
    local argc = vim.fn.argc()
    local should_start = false

    if argc == 0 then
        if is_allowed() then
            should_start = true
        end
    elseif argc == 1 and vim.fn.isdirectory(arg) == 1 then
        M.root_dir = vim.fn.fnamemodify(arg, ":p:h")
        should_start = true
    end

    if should_start then
        M.start()
    end
end

function M.save()
    local file = get_session_path()
    vim.cmd("mks! " .. vim.fn.fnameescape(file))
end

function M.load()
    local file = get_session_path()
    if vim.fn.filereadable(file) == 1 then
        vim.cmd("source " .. vim.fn.fnameescape(file))
    end
end

function M.start()
    M.create_autocmds()
end

function M.stop()
    pcall(vim.api.nvim_clear_autocmds, { group = "aqothy/session" })
end

function M.create_autocmds()
    local group = vim.api.nvim_create_augroup("aqothy/session", { clear = true })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        nested = true,
        callback = function()
            local lazy_view = require("lazy.view")
            if not vim.g.using_stdin and not lazy_view.visible() then
                M.load()
            end
        end,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function(ev)
            local ft = vim.bo[ev.buf].filetype
            if ft == "gitcommit" or ft == "gitrebase" then
                return
            end

            local bufs = vim.tbl_filter(function(b)
                local name = vim.api.nvim_buf_get_name(b)

                return vim.bo[b].buftype == ""
                    and vim.fn.buflisted(b) == 1
                    and name ~= ""
                    -- When opening `nvim .`, buffer 1 is named the CWD path.
                    -- exclude this to prevent saving empty sessions.
                    and vim.fn.isdirectory(name) == 0
            end, vim.api.nvim_list_bufs())

            if #bufs < M.options.need then
                return
            end

            local ok, dv_lib = pcall(require, "diffview.lib")
            if ok and dv_lib and dv_lib.views then
                for _, view in pairs(dv_lib.views) do
                    view:close()
                end
            end

            M.save()
        end,
    })

    vim.api.nvim_create_autocmd("StdinReadPre", {
        group = group,
        once = true,
        callback = function()
            vim.g.using_stdin = true
        end,
    })
end

vim.keymap.set("n", "<leader>rl", M.load, { desc = "Restore Session" })
vim.keymap.set("n", "<leader>ds", M.stop, { desc = "Stop Session" })
vim.keymap.set("n", "<leader>S", M.start, { desc = "Start Session" })

return M
