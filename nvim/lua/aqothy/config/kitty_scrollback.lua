-- Kitty scrollback!
-- Reference: https://gist.github.com/galaxia4Eva/9e91c4f275554b4bd844b6feece16b3d
return function(INPUT_LINE_NUMBER, CURSOR_LINE, CURSOR_COLUMN)
    vim.opt.encoding = "utf-8"
    vim.opt.clipboard = "unnamedplus"
    vim.opt.compatible = false
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.opt.termguicolors = true
    vim.opt.showmode = false
    vim.opt.ruler = false
    vim.opt.laststatus = 0
    vim.opt.cmdheight = 0
    vim.opt.showcmd = false
    vim.opt.scrollback = INPUT_LINE_NUMBER + CURSOR_LINE
    vim.opt.background = "light"
    vim.api.nvim_set_hl(0, "Normal", { bg = "#f2e5bc" }) -- make bg color gruvbox
    vim.api.nvim_set_hl(0, "Visual", { bg = "#BDAE93" })

    local autocmd = vim.api.nvim_create_autocmd
    local group = vim.api.nvim_create_augroup("aqothy/kitty_scrollback", { clear = true })

    -- Highlight on yank
    autocmd("TextYankPost", {
        group = group,
        callback = function()
            (vim.hl or vim.highlight).on_yank({ timeout = 60 })
        end,
    })

    local term_buf = vim.api.nvim_create_buf(true, false)
    local term_io = vim.api.nvim_open_term(term_buf, {})

    vim.api.nvim_buf_set_keymap(term_buf, "n", "q", "<cmd>q<CR>", {})

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
        callback = function(args)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(args.buf, 0, -2, false)) do
                vim.api.nvim_chan_send(term_io, line)
                vim.api.nvim_chan_send(term_io, "\r\n")
            end
            for _, line in ipairs(vim.api.nvim_buf_get_lines(args.buf, -2, -1, false)) do
                vim.api.nvim_chan_send(term_io, line)
            end

            vim.api.nvim_win_set_buf(vim.fn.win_getid(), term_buf)
            vim.api.nvim_buf_delete(args.buf, { force = true })
            vim.schedule(set_cursor)
        end,
    })
end
