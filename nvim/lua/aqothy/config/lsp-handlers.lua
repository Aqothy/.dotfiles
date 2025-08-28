local M = {}

M._capabilities = nil

function M.get_capabilities()
    if M._capabilities then
        return M._capabilities
    end

    M._capabilities = {
        workspace = {
            fileOperations = {
                didRename = true,
                willRename = true,
            },
        },
    }

    M._capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), M._capabilities)

    return M._capabilities
end

function M.setup()
    local config = {
        signs = false,
        virtual_text = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
            focusable = true,
            style = "minimal",
            source = "if_many",
            header = "",
        },
    }

    vim.lsp.log.set_level(vim.log.levels.OFF)

    vim.diagnostic.config(config)

    local register_capability = vim.lsp.handlers["client/registerCapability"]
    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if not client then
            return
        end

        for buffer in pairs(client.attached_buffers) do
            M.on_attach(client, buffer)
        end

        return register_capability(err, res, ctx)
    end
end

local diagnostic_goto = function(next, severity)
    severity = severity and vim.diagnostic.severity[severity] or nil

    return function()
        vim.diagnostic.jump({ count = next and 1 or -1, float = true, severity = severity })
    end
end

function M.has(method, client)
    if type(method) == "table" then
        for _, m in ipairs(method) do
            if M.has(m, client) then
                return true
            end
        end
        return false
    end
    method = method:find("/") and method or "textDocument/" .. method
    if client:supports_method(method) then
        return true
    end
    return false
end

local symbol_opts = {
    filter = {
        default = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
        },
        -- set to `true` to include all symbols
        markdown = true,
        help = true,
    },
}

M._keys = nil

function M.get()
    if M._keys then
        return M._keys
    end

    -- stylua: ignore
    M._keys = {
        { "]d", diagnostic_goto(true), { desc = "Next Diagnostic" } },
        { "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" } },
        { "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" } },
        { "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" } },
        { "<leader>rn", function() Snacks.rename.rename_file() end, { desc = "Rename File", has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } } },
        { "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition", has = "definition" } },
        { "grr", function() Snacks.picker.lsp_references() end, { desc = "References", has = "references" } },
        { "gri", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation", has = "implementation" } },
        { "grt", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto Type Definition", has = "typeDefinition" } },
        { "gO", function() Snacks.picker.lsp_symbols(symbol_opts) end, { desc = "LSP Symbols", has = "documentSymbol" } },
        { "]r", function() Snacks.words.jump(vim.v.count1, true) end, { desc = "Next Word", has = "documentHighlight" } },
        { "[r", function() Snacks.words.jump(-vim.v.count1, true) end, { desc = "Prev Word", has = "documentHighlight" } },
    }

    return M._keys
end

local settings = require("aqothy.config.lsp-settings")

function M.on_attach(client, bufnr)
    if client:supports_method("textDocument/inlineCompletion") then
        vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
        vim.keymap.set("i", "<Tab>", function()
            if not vim.lsp.inline_completion.get() then
                return "<Tab>"
            end
        end, {
            expr = true,
            replace_keycodes = true,
            desc = "Get the current inline completion",
            buffer = bufnr,
        })
    end

    if client:supports_method("textDocument/completion") then
        local triggers = client.server_capabilities.completionProvider.triggerCharacters
        for _, char in ipairs({ "a", "e", "i", "o", "u" }) do
            if not vim.list_contains(triggers, char) then
                table.insert(triggers, char)
            end
        end

        vim.lsp.completion.enable(true, client.id, bufnr, {
            autotrigger = true,
            convert = function(item)
                local label_details = item.labelDetails
                local menu = (label_details and label_details.description) or item.detail or ""

                return {
                    abbr = item.label:gsub("%b()", ""),
                    menu = menu,
                }
            end,
        })

        vim.keymap.set("i", "<c-space>", function()
            vim.lsp.completion.get()
        end, { buffer = bufnr, desc = "Get lsp completion" })
    end

    local keys = vim.tbl_extend("force", {}, M.get())

    local lsp_config = settings[client.name]
    if lsp_config and lsp_config.enabled ~= false and lsp_config.keys then
        vim.list_extend(keys, lsp_config.keys)
    end

    for _, key in pairs(keys) do
        local lhs, rhs, opts, mode = unpack(key)
        mode = mode or "n"

        local has_met = not opts.has or M.has(opts.has, client)

        if has_met then
            opts.cond = nil
            opts.has = nil
            opts.silent = opts.silent ~= false
            opts.buffer = bufnr
            vim.keymap.set(mode, lhs, rhs, opts)
        end
    end
end

return M
