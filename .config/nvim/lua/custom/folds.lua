local M = {}

M.config = {
    fallback = "indent",
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

    local group = vim.api.nvim_create_augroup("aqothy/folds", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        group = group,
        callback = function(ev)
            M.apply(vim.api.nvim_get_current_win(), ev.buf)
        end,
    })
end

return M
