return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
        -- Initialize a variable to track the toggle state
        --        local is_transparent = true

        -- Function to toggle the background
        --        local function toggle_background()
        --            if is_transparent then
        --                -- Set to solid background
        --                vim.api.nvim_set_hl(0, "Normal", { bg = "#32302f" })
        --                vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#32302f" })
        --            else
        --                -- Set to transparent background
        --                vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        --                vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        --            end
        --            is_transparent = not is_transparent
        --        end
        --
        --        -- Key mapping for toggling background
        --        vim.keymap.set("n", "<leader>bt", toggle_background, { desc = "Toggle transparent background" })

        require("gruvbox").setup({
            contrast = "soft", -- can be "hard", "soft" or empty string
            transparent_mode = false,
        })

        vim.cmd("colorscheme gruvbox")
        --        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        --        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
}
