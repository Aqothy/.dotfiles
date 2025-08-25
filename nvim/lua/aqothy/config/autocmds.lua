local function augroup(name)
    return vim.api.nvim_create_augroup("aqothy/" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

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
        "dap*",
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
