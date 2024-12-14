return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-telescope/telescope-project.nvim",
        "nvim-tree/nvim-web-devicons",
        "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local transform_mod = require("telescope.actions.mt").transform_mod

        -- Custom action to send to qflist and open Trouble
        local custom_actions = transform_mod({
            open_trouble_qflist = function()
                vim.cmd("Trouble quickfix")
            end,
        })

        telescope.setup({
            defaults = {
                path_display = { "smart" },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous, -- Move to prev result
                        ["<C-j>"] = actions.move_selection_next,     -- Move to next result
                        ["<C-q>"] = actions.send_to_qflist + custom_actions.open_trouble_qflist,
                    },
                    n = {
                        ["<C-q>"] = actions.send_to_qflist + custom_actions.open_trouble_qflist,
                        ["dd"] = actions.delete_buffer,
                    },
                },
            },
            extensions = {
                fzf = {},
                project = {
                    base_dirs = { "~/Code/Personal" },
                    hidden_files = false, -- default: false
                    order_by = "asc",
                    search_by = "title",
                },
            },
        })

        telescope.load_extension("fzf")
        telescope.load_extension("project")

        -- set keymaps
        local keymap = vim.keymap -- for conciseness
        local builtin = require("telescope.builtin")

        keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
        keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Telescope live grep" })
        keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
        keymap.set("n", "<leader>fp", "<cmd>Telescope project<CR>", { desc = "Find Project" })
    end,
}
