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

-- session

local session_dir = vim.fn.stdpath("state") .. "/sessions/"

local e = vim.fn.fnameescape

local cwd = vim.fn.getcwd()

if vim.fn.isdirectory(session_dir) == 0 then
    vim.fn.mkdir(session_dir, "p")
end

function M.get_session_name()
    -- Turn the path into a filename (replace slashes with %)
    local filename = cwd:gsub("[\\/:]+", "%%") .. ".vim"

    return session_dir .. filename
end

function M.save_session()
    local file = M.get_session_name()
    vim.cmd("mks! " .. e(file))
    vim.notify("Session saved for directory: " .. cwd)
end

function M.load_session()
    local file = M.get_session_name()
    if vim.fn.filereadable(file) == 1 then
        vim.cmd("source " .. e(file))
    end
end

vim.keymap.set("n", "<leader>ps", M.save_session, { silent = true, desc = "Save Session" })

vim.keymap.set("n", "<leader>rl", M.load_session, { silent = true, desc = "Restore Session" })

-- async

function M.run_async(cmd, efm, title, opts)
    if not cmd or cmd == "" then
        vim.notify("No command provided to run_async", vim.log.levels.ERROR)
        return
    end

    opts = opts or {}
    local lines = {}

    vim.notify("Started: " .. title, vim.log.levels.INFO)

    local function on_event(_, data)
        -- sometimes data can have emtpy lines, so dont use vim.list_extend
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
            if opts.no_qf then
                local output = table.concat(lines, "\n")

                if output == "" then
                    output = title .. " finished"
                end

                if exit_code == 0 then
                    vim.notify(output, vim.log.levels.INFO)
                else
                    vim.notify(output, vim.log.levels.ERROR)
                end
                return
            end

            if #lines > 0 then
                if not efm or efm == "" then
                    efm = vim.api.nvim_get_option_value("errorformat", { scope = "global" })
                end

                vim.fn.setqflist({}, "r", {
                    title = title,
                    lines = lines,
                    efm = efm,
                })

                vim.cmd("copen")

                vim.notify(title .. " finished", vim.log.levels.INFO)
            else
                vim.notify(title .. " finished (no output)", vim.log.levels.INFO)
            end
        end,
    })
end

return M
