-- pnpm add -g oxfmt
-- prefer project-configured JS formatters, otherwise fall back to oxfmt
local js_fmt = { "biome", "prettier", "oxfmt", stop_after_first = true }

return {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
        {
            "<leader>i",
            function()
                require("conform").format({ async = true })
            end,
            mode = { "n", "x" },
            desc = "Format",
        },
    },
    opts = {
        log_level = vim.log.levels.OFF,
        notify_on_error = false,
        quiet = true,
        formatters = {
            biome = { require_cwd = true },
            prettier = { require_cwd = true },
        },
        formatters_by_ft = {
            javascript = js_fmt,
            typescript = js_fmt,
            javascriptreact = js_fmt,
            typescriptreact = js_fmt,
            css = js_fmt,
            html = js_fmt,
            json = js_fmt,
            yaml = js_fmt,
            markdown = js_fmt,
            -- brew install stylua
            lua = { "stylua" },
            -- go install golang.org/x/tools/cmd/goimports@latest
            go = { "goimports", "gofmt" },
            rust = { name = "rust_analyzer", lsp_format = "prefer" },
            -- comes with mac
            swift = { "swift" },
            python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
            -- For filetypes without explicit formatter config:
            -- run trims, then run LSP formatter.
            ["_"] = { "trim_whitespace", "trim_newlines", lsp_format = "last" },
        },
        default_format_opts = {
            lsp_format = "fallback",
        },
    },
}
