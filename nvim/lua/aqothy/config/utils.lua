local M = {}

function M.truncateString(str, maxLen)
    if vim.fn.strchars(str) > maxLen then
        return vim.fn.strcharpart(str, 0, maxLen - 1) .. "…"
    else
        return str
    end
end

function M.action(action)
    return vim.lsp.buf.code_action({
        apply = true,
        context = {
            only = { action },
            diagnostics = {},
        },
    })
end

return M
