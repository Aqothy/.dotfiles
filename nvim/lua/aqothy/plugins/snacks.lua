return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true },
        dashboard = {

            enabled = true,

            preset = {

                pick = "fzf-lua",

                keys = {
                    { icon = " ", key = "SPC le", desc = "Leetcode", action = "<cmd>Leet<CR>" },
                    { icon = " ", key = "SPC gs", desc = "Git", action = "<cmd>Git<CR>" },
                    {
                        icon = " ",
                        desc = "Browse Repo",
                        key = "SPC gh",
                        action = function()
                            Snacks.gitbrowse()
                        end,
                    },
                    {
                        icon = "󰱼 ",
                        key = "SPC ff",
                        desc = "Find File",
                        action = function()
                            require("fzf-lua").files()
                        end,
                    },
                    {
                        icon = " ",
                        key = "SPC fs",
                        desc = "Find Word",
                        action = function()
                            require("fzf-lua").live_grep()
                        end,
                    },
                    {
                        icon = " ",
                        key = "SPC of",
                        desc = "Recent Files",
                        action = function()
                            require("fzf-lua").oldfiles()
                        end,
                    },
                    {
                        icon = "󰆴 ",
                        key = "SPC bd",
                        desc = "Remove Dashboard",
                        action = function()
                            Snacks.bufdelete()
                        end,
                    },
                    {
                        icon = " ",
                        key = "ctrl f",
                        desc = "Projects",
                        action = function()
                            project_search()
                        end,
                    },
                    {
                        icon = " ",
                        key = "SPC ee",
                        desc = "File Explorer",
                        action = function()
                            vim.cmd("NvimTreeToggle")
                        end,
                    },
                    -- { icon = " ", key = "c", desc = "Configs", action = "<cmd>e ~/.config/nvim<CR>" },
                    { icon = " ", key = "q", desc = "Quit NVIM", action = "<cmd>qa<CR>" },
                },

                header = [[
             ⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢠⣿⣄⣤⣤⣤⣤⣼⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⣠⣾⣿⣻⡵⠖⠛⠛⠛⢿⣿⣶⣴⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠏⢷⡄⠀⠀⠀
⠀⣤⣤⡾⣯⣿⡿⠋⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣷⣤⣴⣾⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠏⠀⠈⢻⣦⡀⠀
⠀⢹⣿⣴⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⣄⡀⢀⣤⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣶⠀⠈⠻⣦⠀⠀⣼⠋⠀⠀
⠀⣼⢉⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣥⠤⠴⣶⣶⣶⣶⣶⣶⣶⣶⣾⣿⠿⣿⣿⣿⣿⡇⣸⠋⠻⣿⣷
⢰⡏⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣶⣶⣿⣟⣿⣟⣛⣭⣉⣩⣿⣿⡀⣼⣿⣿⣿⣿⣿⣄⠀⣸⣿
⢿⡇⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⣿⣿⣿⠿⠿⠛⠛⠛⠛⠛⠻⣿⣿⣭⣉⢉⣿⣿⠟⣰⣿⡟
⠈⣷⠸⣇⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠞⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠀⠀⠉⣿⣿⡏⢀⣿⡟⠀
⠀⠹⣦⣿⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠞⠋⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣀⠀⠀⠀⠀⣼⣿⡿⢫⣿⣿⡁⠀
⠀⠀⠀⠙⣿⡿⣿⣿⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⣀⣤⠶⠿⢯⡈⠙⣧⡀⠀⠀⣿⣄⣴⣿⣿⠉⠻⣦
⠀⠀⠀⠰⠿⠛⠛⠻⣿⣿⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀⣴⠏⠀⠀⠀⠀⠀⠀⠀⣰⣿⠉⠀⠀⠀⠚⣷⠀⠘⡇⠀⠀⠀⠙⠛⠉⠁⠀⠀⠈
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣹⣿⣽⡿⣿⣷⣦⣀⠀⠀⢰⡟⠀⠀⠀⠀⠀⠀⠀⠀⣿⠽⣄⠀⠀⠀⣠⠟⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠙⠻⣿⣿⣟⣷⣦⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠛⢧⡉⠛⠛⠛⠁⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡟⢉⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠳⠶⠶⠶⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠈⠉⠉⠉⣻⣿⣇⡀⠀⠀⠀⠀⠀⣤⡶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢷⣄⠀⣠⣾⡿⠁⠙⢷⣦⣦⣤⣴⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣴⠶⣆⠀⠀⠀⣾⠉⢻⣿⣿⡀⠀⠀⢿⣿⢉⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣿⠁⢠⡟⠀⠀⠀⣿⠀⠘⣯⠉⠃⠀⠀⠈⢁⣸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣀⣼⡿⠀⠘⣷⠀⠀⠀⣿⠀⠀⢻⡶⠞⢛⡶⠚⢻⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⡾⠋⠁⣀⠀⠀⠈⠳⣄⠀⢸⡆⠀⠈⢷⣄⠟⢁⣠⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢸⡇⠀⠀⠈⢻⡄⠀⠀⠘⢷⣤⣷⡀⠀⠀⠙⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣧⠀⠀⠀⠀⣿⡀⠀⠀⠀⠈⢻⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢹⣄⠀⠀⢀⣿⠁⡀⠀⠀⠀⠀⠻⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣆⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠉⠛⠛⠛⠉⠻⣿⡦⠀⠀⠀⠀⠈⢻⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡇⠀⠀⠀⠀⠀⠀
                ]],
            },

            sections = {
                { section = "header",    align = "center" },
                { section = "startup",   gap = 1,         padding = 1 },
                { header = "Good Luck!", align = "center" },
                {
                    pane = 2,
                    { pane = 2, icon = " ", title = "Recent Projects", section = "projects", indent = 2, padding = 1 },
                    { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                    { section = "keys", gap = 1 },
                },
            },
        },
        indent = {
            indent = {
                enabled = true,
            },
            scope = {
                enabled = false,
            },
        },
        scroll = {
            enabled = false,
        },
        input = { enabled = false },
        notifier = {
            enabled = true,
            level = vim.log.levels.INFO
        },
        quickfile = { enabled = true },
        statuscolumn = {
            enabled = false, -- enabled in set lua
            folds = {
                open = false,
                git_hl = false,
            },
        },
        scope = { enabled = false },
        words = { enabled = false },

        terminal = {
            win = { style = "terminal", height = 0.3 },
        },

        -- scratch = {
        --     win_by_ft = {
        --         javascript = {
        --             keys = {
        --                 ["source"] = {
        --                     "<cr>",
        --                     function(_)
        --                         vim.cmd("w !node")
        --                     end,
        --                     desc = "Source buffer",
        --                     mode = { "n", "x" },
        --                 },
        --             },
        --         },
        --         typescript = {
        --             keys = {
        --                 ["source"] = {
        --                     "<cr>",
        --                     function(_)
        --                         vim.cmd("w !node")
        --                     end,
        --                     desc = "Source buffer",
        --                     mode = { "n", "x" },
        --                 },
        --             },
        --         },
        --         python = {
        --             keys = {
        --                 ["source"] = {
        --                     "<cr>",
        --                     function(_)
        --                         vim.cmd("w !python3")
        --                     end,
        --                     desc = "Source buffer",
        --                     mode = { "n", "x" },
        --                 },
        --             },
        --         },
        --     },
        -- },

        zen = {
            toggles = {
                dim = false,
                indent = false,
            },
            -- temporary solution to removing git signs, its acc pre nice to remove entire sign column
            on_open = function()
                -- require("gitsigns").toggle_signs(false)
                vim.opt.signcolumn = "no"
                vim.opt.statuscolumn = " "
                vim.opt.conceallevel = 3
            end,
            on_close = function()
                -- Re-enable Git signs after exiting Zen Mode
                -- require("gitsigns").toggle_signs(true)
                vim.opt.signcolumn = "yes"
                vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
                vim.opt.conceallevel = 2
            end,
        },

        styles = {
            -- your styles configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            zen = {
                width = 150,
                backdrop = { transparent = false, blend = 40 },
            },
            notification = {
                wo = { wrap = true }, -- Wrap notifications
            },
        },
    },
    keys = {
        { "<leader>nh", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
        -- {
        -- 	"<leader>gg",
        -- 	function()
        -- 		Snacks.git.blame_line()
        -- 	end,
        -- 	desc = "Git Blame Line",
        -- },
        -- {
        --     "<leader>sc",
        --     function()
        --         Snacks.scratch()
        --     end,
        --     desc = "Toggle Scratch Buffer",
        -- },
        -- {
        --     "<leader>sl",
        --     function()
        --         Snacks.scratch.select()
        --     end,
        --     desc = "Select Scratch Buffer",
        -- },
        {
            "<leader>fr",
            function()
                Snacks.rename.rename_file()
            end,
            desc = "Rename File",
        },
        {
            "<leader>gh",
            function()
                Snacks.gitbrowse()
            end,
            desc = "Git Browse",
            mode = { "n", "v" },
        },
        {
            "<c-t>",
            function()
                Snacks.terminal()
            end,
            desc = "Toggle Terminal",
        },
        {
            "<leader>bd",
            function()
                Snacks.bufdelete()
            end,
            desc = "Delete Buffer",
        },
        {
            "<leader>sh",
            function()
                Snacks.notifier.show_history()
            end,
            desc = "Show Notifier History",
        },

        -- {
        -- 	"]]",
        -- 	function()
        -- 		Snacks.words.jump(vim.v.count1)
        -- 	end,
        -- 	desc = "Next Reference",
        -- 	mode = { "n", "t" },
        -- },
        -- {
        -- 	"[[",
        -- 	function()
        -- 		Snacks.words.jump(-vim.v.count1)
        -- 	end,
        -- 	desc = "Prev Reference",
        -- 	mode = { "n", "t" },
        -- },
    },
    config = function(_, opts)
        require("snacks").setup(opts)
        Snacks.toggle.dim():map("<leader>sd")
        Snacks.toggle.zen():map("<leader>zz")
        if vim.lsp.inlay_hint then
            Snacks.toggle.inlay_hints():map("<leader>ti")
        end
        vim.g.snacks_animate = false -- disable animations
    end,
}
