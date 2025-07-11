local M = {}

local has_blink, blink = pcall(require, "blink.cmp")
local has_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local has_cmp, cmp = pcall(require, "cmp")

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
        has_cmp_lsp and cmp_nvim_lsp.default_capabilities() or {},
        has_blink and blink.get_lsp_capabilities() or {},
        M._capabilities
    )

    return M._capabilities
end

function M.setup()
    local user = require("aqothy.config.user")

    local s = vim.diagnostic.severity

    local signs = {
        text = {
            [s.ERROR] = "",
            [s.WARN] = "",
            [s.HINT] = "",
            [s.INFO] = "",
        },
        numhl = {
            [s.ERROR] = "DiagnosticSignError",
            [s.WARN] = "DiagnosticSignWarn",
            [s.HINT] = "DiagnosticSignHint",
            [s.INFO] = "DiagnosticSignInfo",
        },
    }

    local config = {
        signs = signs,
        virtual_text = {
            prefix = function(diagnostic)
                return " " .. user.signs[string.lower(s[diagnostic.severity])]
            end,
        },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
            focusable = true,
            style = "minimal",
            source = "if_many",
            header = "",
            prefix = function(diag)
                local level = string.lower(s[diag.severity])
                local prefix = string.format(" %s ", user.signs[level])
                return prefix, "Diagnostic" .. level:sub(1, 1):upper() .. level:sub(2)
            end,
        },
    }

    vim.diagnostic.config(config)

    vim.lsp.set_log_level("OFF")

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
        { "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" } },
        { "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" } },
        {
            "<c-s>",
            function()
                if has_blink and blink.is_menu_visible() then
                    blink.hide()
                end

                if has_cmp and cmp.visible() then
                    cmp.close()
                end
                vim.lsp.buf.signature_help()
            end,
            { desc = "Signature Help", has = "signatureHelp" },
            { "i", "s" },
        },
        { "<leader>fr", function() Snacks.rename.rename_file() end, { desc = "Rename File", has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } } },
        { "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition", has = "definition" } },
        { "<leader>K", function() Snacks.picker.lsp_definitions({ auto_confirm = false }) end, { desc = "Peek Definition", has = "definition" } },
        { "grr", function() Snacks.picker.lsp_references() end, { desc = "References", has = "references" } },
        { "gri", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation", has = "implementation" } },
        { "grt", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto Type Definition", has = "typeDefinition" } },
        { "<leader>ls", function() Snacks.picker.lsp_symbols(symbol_opts) end, { desc = "LSP Symbols", has = "documentSymbol" } },
        { "<leader>lS", function() Snacks.picker.lsp_workspace_symbols(symbol_opts) end, { desc = "LSP Workspace Symbols", has = "workspace/symbols" } },
        { "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Lsp Declaration", has = "declaration" } },
        { "]r", function() Snacks.words.jump(vim.v.count1, true) end, { desc = "Next Reference", has = "documentHighlight" } },
        { "[r", function() Snacks.words.jump(-vim.v.count1, true) end, { desc = "Prev Reference", has = "documentHighlight" } },
        { "<leader>fd", function() Snacks.picker.diagnostics_buffer() end, { desc = "Document Diagnostics" } },
        { "<leader>fD", function() Snacks.picker.diagnostics() end, { desc = "Workspace Diagnostics" } },
    }

    return M._keys
end

local settings = require("aqothy.config.lsp-settings")

function M.on_attach(client, bufnr)
    -- Inlay hints
    if client:supports_method("textDocument/inlayHint") then
        -- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        Snacks.toggle.inlay_hints():map("<leader>ti")
    end

    vim.lsp.document_color.enable(true, bufnr, { style = "virtual" })

    local keys = vim.tbl_extend("force", {}, M.get())

    local lsp_config = settings[client.name]
    if lsp_config and lsp_config.enabled ~= false and lsp_config.keys then
        vim.list_extend(keys, lsp_config.keys)
    end

    for _, key in pairs(keys) do
        local lhs, rhs, opts, mode = unpack(key)
        mode = mode or "n"

        local has_met = not opts.has or M.has(opts.has, client)
        local cond_met = not (opts.cond == false or ((type(opts.cond) == "function") and not opts.cond()))

        if has_met and cond_met then
            opts.cond = nil
            opts.has = nil
            opts.silent = opts.silent ~= false
            opts.buffer = bufnr
            vim.keymap.set(mode, lhs, rhs, opts)
        end
    end
end

return M
