return {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
        {
            "<leader>=",
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
            -- npm install -g prettier
            javascript = { "prettier" },
            typescript = { "prettier" },
            javascriptreact = { "prettier" },
            typescriptreact = { "prettier" },
            css = { "prettier" },
            html = { "prettier" },
            json = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            -- brew install stylua
            lua = { "stylua" },
            -- go install golang.org/x/tools/cmd/goimports@latest
            go = { "goimports", "gofmt" },
            -- comes with mac
            swift = { "swift" },
            python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
            -- For filetypes without explicit formatter config:
            -- run trims, then run LSP formatter.
            ["_"] = { "trim_whitespace", "trim_newlines", lsp_format = "last" },
        },
        default_format_opts = {
            lsp_format = "fallback",
            timeout_ms = 1200,
        },
    },
}
