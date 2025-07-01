-- Kitty scrollback!
-- Reference: https://gist.github.com/galaxia4Eva/9e91c4f275554b4bd844b6feece16b3d
return function(INPUT_LINE_NUMBER, CURSOR_LINE, CURSOR_COLUMN)
    local opt = vim.opt
    opt.encoding = "utf-8"
    opt.clipboard = "unnamedplus"
    opt.compatible = false
    opt.number = false
    opt.relativenumber = false
    opt.termguicolors = true
    opt.showmode = false
    opt.ruler = false
    opt.laststatus = 0
    opt.cmdheight = 0
    opt.showcmd = false
    opt.scrollback = INPUT_LINE_NUMBER + CURSOR_LINE
    opt.background = "dark"
    vim.api.nvim_set_hl(0, "Normal", { bg = "#32302f" }) -- dark
    vim.api.nvim_set_hl(0, "CurSearch", { bg = "#fe8019" })
    vim.api.nvim_set_hl(0, "Visual", { bg = "#665C54" })

    -- vim.api.nvim_set_hl(0, "Normal", { bg = "#f2e5bc" }) -- light
    -- vim.api.nvim_set_hl(0, "CurSearch", { bg = "#af3a03" })
    -- vim.api.nvim_set_hl(0, "Visual", { bg = "#BDAE93" })

    local autocmd = vim.api.nvim_create_autocmd
    local group = vim.api.nvim_create_augroup("aqothy/kitty_scrollback", { clear = true })

    local term_buf = vim.api.nvim_create_buf(true, false)
    local term_io = vim.api.nvim_open_term(term_buf, {})
    vim.api.nvim_buf_set_keymap(term_buf, "n", "q", "<Cmd>q<CR>", {})

    local set_cursor = function()
        vim.api.nvim_feedkeys(tostring(INPUT_LINE_NUMBER) .. [[ggzt]], "n", true)
        local line = vim.api.nvim_buf_line_count(term_buf)
        if CURSOR_LINE <= line then
            line = CURSOR_LINE
        end
        vim.api.nvim_feedkeys(tostring(line - 1) .. [[j]], "n", true)
        vim.api.nvim_feedkeys([[0]], "n", true)
        vim.api.nvim_feedkeys(tostring(CURSOR_COLUMN - 1) .. [[l]], "n", true)
    end

    -- Highlight on yank
    autocmd("TextYankPost", {
        group = group,
        callback = function()
            (vim.hl or vim.highlight).on_yank({ timeout = 60 })
        end,
    })

    autocmd("ModeChanged", {
        group = group,
        buffer = term_buf,
        callback = function()
            local mode = vim.fn.mode()
            if mode == "t" then
                vim.cmd("stopinsert")
                vim.schedule(set_cursor)
            end
        end,
    })

    autocmd("VimEnter", {
        group = group,
        once = true,
        callback = function(ev)
            local current_win = vim.fn.win_getid()
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, 0, -2, false)) do
                vim.api.nvim_chan_send(term_io, line)
                vim.api.nvim_chan_send(term_io, "\r\n")
            end
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, -2, -1, false)) do
                vim.api.nvim_chan_send(term_io, line)
            end
            vim.api.nvim_win_set_buf(current_win, term_buf)
            vim.api.nvim_buf_delete(ev.buf, { force = true })
            vim.schedule(set_cursor)
        end,
    })
end
