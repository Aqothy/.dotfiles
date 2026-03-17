return {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
        signs = {
            add = { text = "┃" },
            change = { text = "┃" },
            delete = { text = "" },
            topdelete = { text = "" },
            changedelete = { text = "┃" },
            untracked = { text = "┆" },
        },
        signs_staged = {
            add = { text = "┃" },
            change = { text = "┃" },
            delete = { text = "" },
            topdelete = { text = "" },
            changedelete = { text = "┃" },
        },
        attach_to_untracked = true,
        gh = true,
        current_line_blame = true,
        current_line_blame_opts = {
            delay = 200,
        },
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            local line = vim.fn.line
            local next_hunk, prev_hunk = require("custom.repeat").pair(gs.next_hunk, gs.prev_hunk)

            local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc, silent = true })
            end
            map("n", "[h", prev_hunk, "Previous hunk")
            map("n", "]h", next_hunk, "Next hunk")
            map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
            map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
            map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
            map("x", "<leader>hs", function()
                gs.stage_hunk({ line("."), line("v") })
            end, "Stage hunk (visual)")
            map("x", "<leader>hr", function()
                gs.reset_hunk({ line("."), line("v") })
            end, "Reset hunk (visual)")
            map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
            map("n", "<leader>hU", gs.reset_buffer_index, "Unstage Buffer")
            map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
            map("n", "gB", gs.blame, "Blame")
            map("n", "gb", function()
                gs.blame_line({ full = true })
            end, "Blame Line")
            map({ "o", "x" }, "ih", gs.select_hunk, "Select Hunk")
        end,
    },
}
