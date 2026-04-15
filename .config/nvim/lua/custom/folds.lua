local M = {}

local ns = vim.api.nvim_create_namespace("aqothy/foldtext")

M.config = {
    fallback = "indent",
    icon = "󰇘",
}

local function should_skip(win)
    return not win or not vim.api.nvim_win_is_valid(win) or vim.wo[win].diff
end

local priorities = {
    lsp = 1,
    treesitter = 2,
}

local function get_priority(name)
    return priorities[name] or 99
end

local function render_fold_text(win, buf, foldstart)
    local foldend = vim.fn.foldclosedend(foldstart)
    local virt_text = { { " " .. M.config.icon, "Folded" } }

    local line = vim.api.nvim_buf_get_lines(buf, foldstart - 1, foldstart, false)[1]
    if not line then
        return foldend
    end

    local wininfo = vim.fn.getwininfo(win)[1]
    local leftcol = wininfo and wininfo.leftcol or 0
    local wincol = math.max(0, vim.fn.virtcol({ foldstart, line:len() }) - leftcol)

    vim.api.nvim_buf_set_extmark(buf, ns, foldstart - 1, 0, {
        virt_text = virt_text,
        virt_text_win_col = wincol,
        hl_mode = "combine",
        ephemeral = true,
    })

    return foldend
end

function M.apply(win, buf)
    if not vim.api.nvim_buf_is_valid(buf) or should_skip(win) then
        return
    end

    local provider = vim.b[buf].folding_provider or M.config.fallback

    if provider == "lsp" then
        vim.wo[win].foldmethod = "expr"
        vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
    elseif provider == "treesitter" then
        vim.wo[win].foldmethod = "expr"
        vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    else
        vim.wo[win].foldmethod = provider
        vim.wo[win].foldexpr = "0"
    end
end

function M.set_provider(buf, provider)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    local current = vim.b[buf].folding_provider
    if current and get_priority(provider) > get_priority(current) then
        return
    end

    vim.b[buf].folding_provider = provider
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        M.apply(win, buf)
    end
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})

    vim.api.nvim_set_decoration_provider(ns, {
        on_win = function(_, win, buf, topline, botline)
            if should_skip(win) then
                return
            end
            vim.api.nvim_win_call(win, function()
                local line = topline
                while line <= botline do
                    local foldstart = vim.fn.foldclosed(line)
                    if foldstart > -1 then
                        line = render_fold_text(win, buf, foldstart)
                    end
                    line = line + 1
                end
            end)
        end,
    })

    local group = vim.api.nvim_create_augroup("aqothy/folds", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        group = group,
        callback = function(ev)
            M.apply(vim.api.nvim_get_current_win(), ev.buf)
        end,
    })
end

return M
