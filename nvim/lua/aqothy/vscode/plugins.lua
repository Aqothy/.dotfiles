return {
    {
        "kylechui/nvim-surround",
        keys = {
            { "<C-g>s", mode = "i", desc = "Add Surround In Insert Mode" },
            { "<C-g>S", mode = "i", desc = "Add Surround On New Lines In Insert Mode" },
            { "gz", mode = { "n", "v" }, desc = "Surround Normal And Visual" },
            { "gzz", mode = "n", desc = "Surround Current Line" },
            { "gZ", mode = "n", desc = "Surround On New Lines" },
            { "gZZ", mode = "n", desc = "Surround Current Line On New Lines" },
            { "Z", mode = "v", desc = "Surround Visual Selection On New Lines" },
            { "ds", mode = "n", desc = "Delete Surrounding" },
            { "cs", mode = "n", desc = "Change Surrounding" },
            { "cS", mode = "n", desc = "Change Surrounding On New Lines" },
        },
        opts = {
            keymaps = {
                insert = "<C-g>s",
                insert_line = "<C-g>S",
                normal = "gz",
                normal_cur = "gzz",
                normal_line = "gZ",
                normal_cur_line = "gZZ",
                visual = "gz",
                visual_line = "Z",
                delete = "ds",
                change = "cs",
                change_line = "cS",
            },
        },
    },
    {
        "folke/snacks.nvim",
        opts = {},
        -- stylua: ignore
        keys = {
            { "<leader>gh", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
            ---@diagnostic disable-next-line: missing-fields
            { "<leader>gy", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, desc = "Git Browse (copy)", mode = { "n", "v" } },
        },
    },
    {
        "ggandor/leap.nvim",
        keys = {
            { "<leader>;", "<Plug>(leap)", mode = { "n", "x", "o" }, desc = "Leap" },
        },
        opts = {
            preview_filter = function(ch0, ch1, ch2)
                return not (ch1:match("%s") or ch0:match("%a") and ch1:match("%a") and ch2:match("%a"))
            end,
            equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" },
            labels = "asdfghjklqwertyuiopzxcvbnm",
            safe_labels = "",
        },
    },
}
