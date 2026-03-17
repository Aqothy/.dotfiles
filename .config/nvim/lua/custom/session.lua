local M = {}

M.options = {
    auto_start = false,
    autosave = false,
    allowed_dirs = {},
    need_tabs = 1,
    dir = vim.fn.stdpath("state") .. "/sessions/",
    hooks = {
        before_save = function() end,
    },
}

M.root_dir = vim.fn.getcwd()
M.attached = false

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

    vim.keymap.set("n", "<leader>Sl", M.load, { desc = "Restore Session" })
    vim.keymap.set("n", "<leader>Sd", function()
        M.stop()
        vim.notify("Session detached", vim.log.levels.INFO)
    end, { desc = "Detach Session" })
    vim.keymap.set("n", "<leader>Ss", function()
        M.start()
        vim.notify("Session attached", vim.log.levels.INFO)
    end, { desc = "Attach Session" })

    vim.fn.mkdir(M.options.dir, "p")
    M.create_autocmds()
end

function M.save()
    local file = get_session_path()
    vim.cmd("mks! " .. vim.fn.fnameescape(file))
end

function M.exists()
    local file = get_session_path()
    return vim.fn.filereadable(file) == 1
end

function M.load()
    local file = get_session_path()
    if vim.fn.filereadable(file) == 1 then
        vim.cmd("source " .. vim.fn.fnameescape(file))
        M.start()
    end
end

function M.start()
    M.attached = true
end

function M.stop()
    M.attached = false
end

function M.create_autocmds()
    local group = vim.api.nvim_create_augroup("aqothy/session", { clear = true })

    if M.options.auto_start then
        vim.api.nvim_create_autocmd("VimEnter", {
            group = group,
            once = true,
            nested = true,
            callback = function()
                local lazy_view = require("lazy.view")
                if vim.fn.argc() == 0 and is_allowed() and not vim.g.using_stdin and not lazy_view.visible() then
                    M.load()
                end
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

    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function(ev)
            if not M.attached and not (M.options.autosave and is_allowed()) then
                return
            end

            local ft = vim.bo[ev.buf].filetype
            if ft == "gitcommit" or ft == "gitrebase" then
                return
            end

            M.options.hooks.before_save()

            local tabs = vim.api.nvim_list_tabpages()

            if #tabs < M.options.need_tabs then
                return
            end

            M.save()
        end,
    })
end

return M
