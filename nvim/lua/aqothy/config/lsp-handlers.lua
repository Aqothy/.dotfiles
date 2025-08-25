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
    local user = require("aqothy.config.icons")

    local s = vim.diagnostic.severity

    local config = {
        signs = false,
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
        },
    }

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
        { "<leader>rn", function() Snacks.rename.rename_file() end, { desc = "Rename File" } },
        { "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" } },
        { "grr", function() Snacks.picker.lsp_references() end, { desc = "References" } },
        { "gri", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" } },
        { "grt", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto Type Definition" } },
        { "gO", function() Snacks.picker.lsp_symbols(symbol_opts) end, { desc = "LSP Symbols" } },
        { "]r", function() Snacks.words.jump(vim.v.count1, true) end, { desc = "Next Word" } },
        { "[r", function() Snacks.words.jump(-vim.v.count1, true) end, { desc = "Prev Word" } },
    }

    return M._keys
end

local settings = require("aqothy.config.lsp-settings")

function M.on_attach(client, bufnr)
    local keys = vim.tbl_extend("force", {}, M.get())

    local lsp_config = settings[client.name]
    if lsp_config and lsp_config.enabled ~= false and lsp_config.keys then
        vim.list_extend(keys, lsp_config.keys)
    end

    for _, key in pairs(keys) do
        local lhs, rhs, opts, mode = unpack(key)
        mode = mode or "n"

        opts.silent = opts.silent ~= false
        opts.buffer = bufnr
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

return M
