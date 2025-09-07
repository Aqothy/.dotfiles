local M = {}

local has_blink, blink = pcall(require, "blink.cmp")

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

    M._capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        has_blink and blink.get_lsp_capabilities() or {},
        M._capabilities
    )

    return M._capabilities
end

function M.setup()
    local config = {
        signs = false,
        virtual_text = true,
        update_in_insert = false,
        underline = { severity = vim.diagnostic.severity.ERROR },
        severity_sort = true,
        float = {
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

function M.has(method, client)
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
    },
}

M._keys = nil

function M.get()
    if M._keys then
        return M._keys
    end

    -- stylua: ignore
    M._keys = {
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
    if client:supports_method("textDocument/linkedEditingRange") then
        vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
    end

    client.server_capabilities.semanticTokensProvider = nil

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
            opts.has = nil
            opts.silent = opts.silent ~= false
            opts.buffer = bufnr
            vim.keymap.set(mode, lhs, rhs, opts)
        end
    end
end

return M
