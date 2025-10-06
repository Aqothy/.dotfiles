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

function M.bufname_valid(bufname)
    if
        bufname:match("^/")
        or bufname:match("^[a-zA-Z]:")
        or bufname:match("^zipfile://")
        or bufname:match("^tarfile:")
    then
        return true
    end
    return false
end

-- treesitter

M._installed = nil
M._queries = {}

function M.get_installed_parsers(update)
    if update then
        M._installed, M._queries = {}, {}
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

return M
