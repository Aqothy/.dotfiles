local M = {}

local has_blink, blink = pcall(require, "blink.cmp")

M.capabilities = {
    workspace = {
        fileOperations = {
            didRename = true,
            willRename = true,
        },
    },
}

M.capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    has_blink and blink.get_lsp_capabilities() or {},
    M.capabilities
)

local icons = require("aqothy.config.icons")

local diagnostic_ui = {
    [vim.diagnostic.severity.ERROR] = { icons.diagnostics.Error .. " ", "DiagnosticError" },
    [vim.diagnostic.severity.WARN] = { icons.diagnostics.Warn .. " ", "DiagnosticWarn" },
    [vim.diagnostic.severity.INFO] = { icons.diagnostics.Info .. " ", "DiagnosticInfo" },
    [vim.diagnostic.severity.HINT] = { icons.diagnostics.Hint .. " ", "DiagnosticHint" },
}

function M.setup()
    local config = {
        signs = false,
        virtual_text = {
            prefix = function(diagnostic)
                return diagnostic_ui[diagnostic.severity][1] or "● "
            end,
        },
        update_in_insert = false,
        underline = { severity = vim.diagnostic.severity.ERROR },
        severity_sort = true,
        float = {
            style = "minimal",
            source = "if_many",
            header = "",
            prefix = function(diagnostic)
                local severity = diagnostic.severity
                local icon = diagnostic_ui[severity][1] or "● "
                return " " .. icon, diagnostic_ui[severity][2]
            end,
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

function M.has(method, client, bufnr)
    method = method:find("/") and method or "textDocument/" .. method
    return client:supports_method(method, bufnr)
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

-- stylua: ignore
M.keys = {
    { lhs = "<c-k>", rhs = vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp", mode = { "i", "s" } },
    { lhs = "gd", rhs = function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
    { lhs = "grr", rhs = function() Snacks.picker.lsp_references() end, desc = "References", has = "references" },
    { lhs = "gri", rhs = function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation", has = "implementation" },
    { lhs = "grt", rhs = function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition", has = "typeDefinition" },
    { lhs = "gO", rhs = function() Snacks.picker.lsp_symbols(symbol_opts) end, desc = "LSP Symbols", has = "documentSymbol" },
    { lhs = "]r", rhs = function() Snacks.words.jump(vim.v.count1, true) end, desc = "Next Word", has = "documentHighlight" },
    { lhs = "[r", rhs = function() Snacks.words.jump(-vim.v.count1, true) end, desc = "Prev Word", has = "documentHighlight" },
}

function M.on_attach(client, bufnr)
    client.server_capabilities.semanticTokensProvider = nil

    if client:supports_method("textDocument/linkedEditingRange", bufnr) then
        vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
    end

    for _, key in ipairs(M.keys) do
        if M.has(key.has, client, bufnr) then
            vim.keymap.set(key.mode or "n", key.lhs, key.rhs, {
                buffer = bufnr,
                silent = key.silent ~= false,
                desc = key.desc,
            })
        end
    end
end

return M
