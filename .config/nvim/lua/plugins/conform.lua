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
        formatters_by_ft = {
            -- pnpm add -g oxfmt
            javascript = { "oxfmt" },
            typescript = { "oxfmt" },
            javascriptreact = { "oxfmt" },
            typescriptreact = { "oxfmt" },
            css = { "oxfmt" },
            html = { "oxfmt" },
            json = { "oxfmt" },
            yaml = { "oxfmt" },
            markdown = { "oxfmt" },
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
