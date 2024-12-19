return {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local fzf = require("fzf-lua")

        local actions = require("fzf-lua.actions")

        function _G.project_search()
            fzf.fzf_exec(
                "echo ~/.config; find ~/.config ~/Code ~/Code/School ~/Code/Personal ~/Documents/documents-mac ~/Documents/documents-mac/school ~/Documents ~/Documents/documents-mac -mindepth 1 -maxdepth 1 -type d",
                {
                    prompt = "Select a project> ",
                    actions = {
                        ["default"] = function(selected)
                            -- Use the chosen directory as the cwd for file search
                            fzf.files({ cwd = selected[1] })
                        end,
                    },
                }
            )
        end

        fzf.setup({
            -- Global defaults for all pickers
            defaults = {
                -- formatter = "path.filename_first",
                formatter = "path.dirname_first",
            },
            previewers = {
                builtin = {
                    syntax_limit_b = 1024 * 512
                },
            },
            keymap = {
                builtin = {
                    ["<c-d>"] = "preview-page-down",
                    ["<c-u>"] = "preview-page-up",
                },
            },
            winopts = {
                width = 0.8,
                height = 0.8,
                row = 0.5,
                col = 0.5,
                preview = {
                    scrollchars = { "┃", "" },
                },
            },
            fzf_opts = {
                ["--layout"] = "default",
            },
            files = {
                -- fd_opts = "--type f --hidden --follow --exclude .git --exclude node_modules",
                cwd_prompt = false,
                actions = {
                    ["ctrl-i"] = { actions.toggle_ignore },
                    ["ctrl-h"] = { actions.toggle_hidden },
                    ["ctrl-q"] = actions.file_sel_to_qf,
                },
            },
            grep = {
                -- rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --follow --glob '!.git/' --glob '!node_modules'",
                actions = {
                    ["ctrl-i"] = { actions.toggle_ignore },
                    ["ctrl-h"] = { actions.toggle_hidden },
                    ["ctrl-q"] = actions.file_sel_to_qf,
                },
            },
            oldfiles = {
                include_current_session = true
            },
        })

        -- Register fzf-lua as vim.ui.select for a UI-select-like experience
        fzf.register_ui_select()

        -- Keymaps to mimic your Telescope ones:
        local keymap = vim.keymap
        keymap.set("n", "<leader>ff", function()
            fzf.files()
        end, { desc = "Fzf-lua find files" })
        keymap.set("n", "<leader>fs", function()
            fzf.live_grep()
        end, { desc = "Fzf-lua live grep" })
        -- git comiits
        keymap.set("n", "<leader>gc", function()
            fzf.git_commits()
        end, { desc = "Fzf-lua git commits" })
        -- git branches
        keymap.set("n", "<leader>gb", function()
            fzf.git_branches()
        end, { desc = "Fzf-lua git branches" })
        -- git blame
        -- keymap.set("n", "<leader>gB", function()
        --     fzf.git_blame()
        -- end, { desc = "Fzf-lua git blame" })
        keymap.set(
            "n",
            "<leader>fb",
            "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
            { desc = "Fzf-lua buffers" }
        )
        keymap.set("n", "<leader>of", function()
            fzf.oldfiles()
        end, { desc = "Fzf-lua old files" })
        keymap.set("n", "<leader>fp", project_search, { desc = "Find Project" })
        keymap.set("n", "<leader>fh", function()
            fzf.help_tags()
        end, { desc = "[F]ind [H]elp" })
    end,
}
