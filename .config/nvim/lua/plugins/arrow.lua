return {
    "Aqothy/arrow.nvim",
    -- stylua: ignore
    keys = {
        { "'", desc = "Arrow" },
        { "m", desc = "Mark Buffer Loc" },
        { "<a-n>", function() require("arrow.persist").next() end, desc = "Next Mark" },
        { "<a-p>", function() require("arrow.persist").previous() end, desc = "Previous Mark" },
    },
    event = "BufReadPost",
    opts = {
        show_icons = true,
        buffer_leader_key = "m",
        leader_key = "'",
        hide_handbook = true,
        hide_buffer_handbook = true,
        window = {
            border = "rounded",
        },
        custom_actions = {
            open = function(target_file_name)
                local cur_file = vim.fn.expand("%:.")
                if cur_file ~= target_file_name then
                    vim.cmd.edit(target_file_name)
                end
            end,
        },
        per_buffer_config = {
            lines = 6,
        },
    },
}
