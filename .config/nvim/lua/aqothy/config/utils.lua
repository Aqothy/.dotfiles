local M = {}

-- lsp

function M.action(action)
    return vim.lsp.buf.code_action({
        apply = true,
        context = {
            only = { action },
            diagnostics = {},
        },
    })
end

-- treesitter

M._installed = nil
M._queries = {}
M._filetypes = nil

function M.get_installed_parsers(update)
    if update then
        M._installed, M._queries, M._filetypes = {}, {}, nil
        for _, lang in ipairs(require("nvim-treesitter").get_installed("parsers")) do
            M._installed[lang] = true
        end
    end
    return M._installed or {}
end

function M.have_query(lang, query)
    local key = lang .. ":" .. query
    if M._queries[key] == nil then
        M._queries[key] = vim.treesitter.query.get(lang, query) ~= nil
    end
    return M._queries[key]
end

function M.have(ft, query)
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang or not M.get_installed_parsers()[lang] then
        return false
    end
    if query and not M.have_query(lang, query) then
        return false
    end
    return true
end

function M.filetypes_from_langs(langs)
    if M._filetypes then
        return M._filetypes
    end
    local ft_set = {}
    for _, lang in ipairs(langs or {}) do
        for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang) or {}) do
            ft_set[ft] = true
        end
    end
    local filetypes = vim.tbl_keys(ft_set)
    M._filetypes = filetypes
    return M._filetypes
end

return M
