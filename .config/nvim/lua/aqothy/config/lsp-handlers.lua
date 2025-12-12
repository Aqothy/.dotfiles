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

local s = vim.diagnostic.severity

local sev_list = {
    ["ERROR"] = "Error",
    ["WARN"] = "Warn",
    ["INFO"] = "Info",
    ["HINT"] = "Hint",
}

function M.setup()
    local config = {
        signs = false,
        virtual_text = {
            prefix = function(diagnostic)
                return (icons.diagnostics[sev_list[s[diagnostic.severity]]] or "●") .. " "
            end,
        },
        update_in_insert = false,
        underline = { severity = { min = vim.diagnostic.severity.WARN } },
        severity_sort = true,
        float = {
            style = "minimal",
            source = "if_many",
            header = "",
            prefix = "",
        },
    }

    vim.lsp.log.set_level(vim.log.levels.OFF)

    vim.diagnostic.config(config)

    local register_capability = vim.lsp.handlers["client/registerCapability"]
    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        vim.schedule(function()
            local client = vim.lsp.get_client_by_id(ctx.client_id)
            if not client then
                return
            end

            for buffer in pairs(client.attached_buffers) do
                M.on_attach(client, buffer)
            end
        end)

        return register_capability(err, res, ctx)
    end
end

function M.has(method, client, bufnr)
    method = method:find("/") and method or "textDocument/" .. method
    return client:supports_method(method, bufnr)
end

-- stylua: ignore
M.keys = {
    { lhs = "gK", rhs = vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" },
    { lhs = "gd", rhs = function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
    { lhs = "grr", rhs = function() Snacks.picker.lsp_references() end, desc = "References", has = "references" },
    { lhs = "gri", rhs = function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation", has = "implementation" },
    { lhs = "grt", rhs = function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition", has = "typeDefinition" },
    { lhs = "gO", rhs = function() Snacks.picker.lsp_symbols() end, desc = "Lsp Symbols", has = "documentSymbol" },
    { lhs = "<leader>ls", rhs = function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols", has = "documentSymbol" },
    { lhs = "<a-n>", rhs = function() Snacks.words.jump(vim.v.count1, true) end, desc = "Next Word", has = "documentHighlight" },
    { lhs = "<a-p>", rhs = function() Snacks.words.jump(-vim.v.count1, true) end, desc = "Prev Word", has = "documentHighlight" },
    { lhs = "<leader>li", rhs = function() Snacks.picker.lsp_incoming_calls() end, desc = "Incoming Calls", has = "callHierarchy/incomingCalls" },
    { lhs = "<leader>lo", rhs = function() Snacks.picker.lsp_outgoing_calls() end, desc = "Outgoing Calls", has = "callHierarchy/outgoingCalls" },
    { lhs = "<M-i>", rhs = function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, desc = "Inlay Hints", has = "inlayHint" },
}

function M.on_attach(client, bufnr)
    vim.lsp.semantic_tokens.enable(false, { bufnr = bufnr })
    vim.lsp.document_color.enable(true, bufnr, { style = "virtual" })

    for _, key in ipairs(M.keys) do
        local has = not key.has or M.has(key.has, client, bufnr)
        if has then
            vim.keymap.set(key.mode or "n", key.lhs, key.rhs, {
                buffer = bufnr,
                silent = key.silent ~= false,
                desc = key.desc,
            })
        end
    end
end

return M
