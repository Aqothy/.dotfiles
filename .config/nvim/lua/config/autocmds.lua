local function augroup(name)
    return vim.api.nvim_create_augroup("aqothy/" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- Check file changes after using term
autocmd({ "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function(ev)
        if vim.bo[ev.buf].buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- Highlight on yank
autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        (vim.hl or vim.highlight).on_yank({ timeout = 60 })
    end,
})

-- close some filetypes with <q>
autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "help",
        "git",
        "checkhealth",
        "qf",
        "vim",
        "query",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].aqothy_last_loc then
            return
        end
        vim.b[buf].aqothy_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
            vim.cmd("normal! zz")
        end
    end,
})

local function setup_git_env()
    local home = vim.fn.expand("~")
    local cwd = vim.fn.getcwd()
    local git_dir = home .. "/.dotfiles"
    local result = vim.fn.system(
        string.format("git --git-dir=%s --work-tree=%s ls-files %s", git_dir, home, vim.fn.shellescape(cwd))
    )

    if result ~= "" then
        vim.env.GIT_DIR = git_dir
        vim.env.GIT_WORK_TREE = home
    else
        vim.env.GIT_DIR = nil
        vim.env.GIT_WORK_TREE = nil
    end
end

setup_git_env()

autocmd("DirChanged", {
    group = augroup("git_env_on_dir_change"),
    callback = setup_git_env,
})
