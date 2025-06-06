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

    local has_blink, blink = pcall(require, "blink.cmp")

    M._capabilities = has_blink and blink.get_lsp_capabilities(M._capabilities, true) or {}

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

    vim.lsp.log.set_level(vim.log.levels.OFF)

    local float_config = {
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }

    local hover = vim.lsp.buf.hover
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.lsp.buf.hover = function()
        return hover(float_config)
    end

    local signature_help = vim.lsp.buf.signature_help
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.lsp.buf.signature_help = function()
        return signature_help(float_config)
    end

    --- HACK: Override `vim.lsp.util.stylize_markdown` to use Treesitter.
    ---@param bufnr integer
    ---@param contents string[]
    ---@param opts table
    ---@return string[]
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.lsp.util.stylize_markdown = function(bufnr, contents, opts)
        contents = vim.lsp.util._normalize_markdown(contents, {
            width = vim.lsp.util._make_floating_popup_size(contents, opts),
        })
        vim.bo[bufnr].filetype = "markdown"
        vim.treesitter.start(bufnr)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)

        return contents
    end

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

M._keys = nil

function M.get()
    if M._keys then
        return M._keys
    end
    -- stylua: ignore
    M._keys = {
        { "n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" } },
        { "n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" } },
        { "n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" } },
        { "n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" } },
        { "n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" } },
        { "n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" } },
        {
            { "i", "s", "n" },
            "<c-s>",
            function()
                local has_blink, blink = pcall(require, "blink.cmp")
                if has_blink and blink.is_menu_visible() then
                    blink.hide()
                end
                vim.lsp.buf.signature_help()
            end,
            { desc = "Signature Help", has = "signatureHelp" },
        },
        { "n", "<leader>fr", function() Snacks.rename.rename_file() end, { desc = "Rename File", has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } } },
        { "n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition", has = "definition" } },
        { "n", "grr", function() Snacks.picker.lsp_references() end, { desc = "References", has = "references" } },
        { "n", "gri", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation", has = "implementation" } },
        { "n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto Type Definition", has = "typeDefinition" } },
        { "n", "<leader>ls", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols", has = "documentSymbol" } },
        { "n", "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols", has = "workspace/symbols" } },
        { "n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Lsp Declaration", has = "declaration" } },
        { "n", "]r", function() Snacks.words.jump(vim.v.count1, true) end, { desc = "Next Reference", has = "documentHighlight", cond = function() return Snacks.words.is_enabled() end } },
        { "n", "[r", function() Snacks.words.jump(-vim.v.count1, true) end, { desc = "Prev Reference", has = "documentHighlight", cond = function() return Snacks.words.is_enabled() end } },
        { "n", "<leader>fd", function() Snacks.picker.diagnostics_buffer() end, { desc = "Document Diagnostics" } },
        { "n", "<leader>fD", function() Snacks.picker.diagnostics() end, { desc = "Workspace Diagnostics" } },
    }

    return M._keys
end

local settings = require("aqothy.config.lsp-settings")

M.on_attach = function(client, bufnr)
    -- Inlay hints
    if client:supports_method("textDocument/inlayHint") then
        -- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        Snacks.toggle.inlay_hints():map("<leader>ti")
    end

    vim.lsp.document_color.enable(true, bufnr, { style = "virtual" })

    local keys = vim.tbl_extend("force", {}, M.get())

    local lsp_config = settings[client.name]
    if lsp_config and lsp_config.enabled and lsp_config.keys then
        vim.list_extend(keys, lsp_config.keys)
    end

    for _, key in pairs(keys) do
        local mode, lhs, rhs, opts = unpack(key)
        local has_met = not opts.has or M.has(opts.has, client)
        local cond_met = not (opts.cond == false or ((type(opts.cond) == "function") and not opts.cond()))

        if has_met and cond_met then
            opts.cond = nil
            opts.has = nil
            opts.silent = opts.silent ~= false
            opts.buffer = bufnr
            vim.keymap.set(mode or "n", lhs, rhs, opts)
        end
    end
end

return M
