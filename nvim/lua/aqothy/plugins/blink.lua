return {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdLineEnter" },
    opts = {
        keymap = {
            preset = "enter",
            ["<Tab>"] = {
                function()
                    local ok, suggestion = pcall(vim.fn["copilot#GetDisplayedSuggestion"])
                    if ok and type(suggestion) == "table" and suggestion.text ~= "" then
                        local line = vim.api.nvim_get_current_line()
                        local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
                        local prefix = cursor_col == 0 and "" or line:sub(1, cursor_col)

                        if prefix:match("^%s*$") then
                            local missing_indent = (suggestion.text or ""):match("^(%s+)")
                            if missing_indent then
                                return nil
                            end
                        end

                        local accept = vim.fn["copilot#Accept"]("")
                        if accept ~= "" then
                            return accept
                        end
                    end

                    return nil
                end,
                "snippet_forward",
                "fallback",
            },
            ["<Up>"] = false,
            ["<Down>"] = false,
        },
        cmdline = {
            enabled = true,
            keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
            completion = {
                menu = { auto_show = true },
                list = {
                    selection = {
                        auto_insert = false,
                    },
                },
            },
        },
        completion = {
            list = {
                max_items = 30,
                selection = { auto_insert = false },
            },
        },
        fuzzy = {
            implementation = "lua",
            sorts = {
                "exact",
                "score",
                "sort_text",
            },
        },
        appearance = {
            kind_icons = require("aqothy.config.icons").kinds,
        },
    },
}
