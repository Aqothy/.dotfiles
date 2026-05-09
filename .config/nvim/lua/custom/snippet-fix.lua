-- fix nested snippet placeholders taken from lazyvim
local M = {}

function M.snippet_replace(snippet, fn)
    local result, _ = snippet:gsub("%$%b{}", function(m)
        local n, name = m:match("^%${(%d+):(.*)}$")
        return n and fn({ n = n, text = name }) or m
    end)
    return result
end

local function escape(text)
    return text:gsub("([\\}$])", "\\%1")
end

function M.snippet_preview(snippet)
    local ok, parsed = pcall(function()
        return vim.lsp._snippet_grammar.parse(snippet)
    end)
    if ok then
        -- Grammar parser strips escapes (e.g. \} -> }); re-escape for correct expand
        return escape(tostring(parsed))
    end
    return M.snippet_replace(snippet, function(placeholder)
        return M.snippet_preview(placeholder.text)
    end):gsub("%$0", "")
end

function M.snippet_fix(snippet)
    local texts = {}
    return M.snippet_replace(snippet, function(placeholder)
        texts[placeholder.n] = texts[placeholder.n] or M.snippet_preview(placeholder.text)
        return "${" .. placeholder.n .. ":" .. texts[placeholder.n] .. "}"
    end)
end

function M.expand(snippet)
    local ok, err = pcall(vim.snippet.expand, snippet)
    if not ok then
        local fixed = M.snippet_fix(snippet)
        ok, err = pcall(vim.snippet.expand, fixed)

        if not ok then
            vim.notify(
                "Failed to expand snippet.\n" .. err .. "\n```" .. vim.bo.filetype .. "\n" .. snippet .. "\n```",
                vim.log.levels.WARN
            )
        end
    end
end

return M
