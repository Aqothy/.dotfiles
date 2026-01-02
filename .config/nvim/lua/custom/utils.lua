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

M.ensure_installed = {
    "c",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",

    -- extras
    "javascript",
    "typescript",
    "cpp",
    "go",
    "bash",
    "tsx",
    "json",
    "swift",
    "python",
    "regex",
}
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
        local ok, res = pcall(vim.treesitter.query.get, lang, query)
        M._queries[key] = ok and res ~= nil
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

function M.get_ensured_parsers_fts()
    local ft_set = {}
    for _, lang in ipairs(M.ensure_installed) do
        for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang) or {}) do
            ft_set[ft] = true
        end
    end
    return vim.tbl_keys(ft_set)
end

-- async

function M.run_async(cmd, efm, title, opts)
    if not cmd or cmd == "" then
        return vim.notify("No command provided", vim.log.levels.ERROR)
    end

    opts = opts or {}
    local lines = {}

    local function on_event(_, data)
        if data then
            for _, line in ipairs(data) do
                if line ~= "" then
                    table.insert(lines, line)
                end
            end
        end
    end

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = on_event,
        on_stderr = on_event,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if not efm or efm == "" then
                    efm = vim.api.nvim_get_option_value("errorformat", { scope = "global" })
                end

                vim.fn.setqflist({}, "r", {
                    title = title,
                    lines = lines,
                    efm = efm,
                })

                if not opts.bang then
                    vim.cmd("copen")
                end

                local msg = title .. (exit_code == 0 and ": Success" or ": Failed")
                local level = exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
                vim.notify(msg, level)
            end)
        end,
    })
end

return M
