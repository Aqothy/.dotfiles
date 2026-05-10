local function get_branch()
    for _, branch in ipairs({ "origin/main", "origin/master", "main" }) do
        local result = vim.fn.systemlist({ "git", "rev-parse", "--verify", branch })
        if vim.v.shell_error == 0 and result[1] ~= nil and result[1] ~= "" then
            return branch
        end
    end

    return "master"
end

return {
    -- maintained fork of diffview
    "dlyongemallo/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
        { "<leader>gd", "<cmd>DiffviewToggle<cr>", desc = "Toggle Diffview" },
        { "<leader>gh", ":DiffviewFileHistory %<cr>", mode = { "n", "x" }, desc = "Diff File/Selection History" },
        { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", mode = "n", desc = "Diff Repo History" },
        {
            "<leader>gm",
            function()
                vim.cmd("DiffviewOpen " .. get_branch())
            end,
            desc = "Diff Main",
        },
        {
            "<leader>gr",
            function()
                vim.cmd("DiffviewOpen " .. get_branch() .. "...HEAD")
            end,
            desc = "Git Review (vs main)",
        },
    },
    opts = {
        clean_up_buffers = true,
        hide_merge_artifacts = true,
        enhanced_diff_hl = true,
        show_help_hints = false,
        view = {
            merge_tool = {
                layout = "diff3_mixed",
            },
            cycle_layouts = {
                default = { "diff2_horizontal", "diff1_inline" },
                merge_tool = { "diff4_mixed", "diff3_mixed", "diff3_horizontal", "diff1_plain" },
            },
            foldlevel = 99,
        },
        file_panel = {
            listing_style = "list",
            show_branch_name = true,
            win_config = {
                win_opts = {
                    signcolumn = "no",
                },
            },
        },
        file_history_panel = {
            win_config = {
                height = 12,
            },
        },
        default_args = {
            DiffviewOpen = { "--imply-local" },
        },
    },
}
