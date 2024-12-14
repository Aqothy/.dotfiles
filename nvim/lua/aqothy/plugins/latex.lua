return {
    {
        "lervag/vimtex", -- Main LaTeX plugin for Neovim
        lazy = false,
        tag = "v2.15",
        config = function()
            -- Configuration for vimtex
            vim.g.vimtex_view_method = "skim" -- PDF viewer
            vim.g.vimtex_compiler_method = "latexmk" -- Auto compile with latexmk
            vim.g.vimtex_quickfix_mode = 0  -- Don't open quickfix window_picker
            -- dont need it anymore since local map leader is set
            --			vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>", { desc = "Open VimTeX PDF viewer" })
            --			vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { desc = "Start VimTeX compilation" })
            -- inverse search and focus back to terminal
            local function focus_terminal()
                -- Replace "Kitty" with the name of your terminal app if it's different
                vim.fn.system({ "open", "-a", "Kitty" })
            end

            -- Register the function for the Vimtex inverse search event
            vim.api.nvim_create_augroup("vimtex_event_focus", { clear = true })

            vim.api.nvim_create_autocmd("User", {
                pattern = "VimtexEventViewReverse",
                group = "vimtex_event_focus",
                callback = focus_terminal,
            })

            vim.g.vimtex_compiler_latexmk = {
                aux_dir = "aux",
                options = {
                    "-file-line-error",
                    "-interaction=nonstopmode",
                    "-synctex=1",
                    "-shell-escape",
                },
            }
        end,
    },
}
