return {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
        file = {
            ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
            [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
            [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
            ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
            ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
            ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
            ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
        },
        filetype = {
            dotenv = { glyph = "", hl = "MiniIconsYellow" },
            go = { glyph = "", hl = "MiniIconsAzure" },
            kitty = { glyph = "󰄛", hl = "MiniIconsOrange" },
        },
    },
    init = function()
        package.preload["nvim-web-devicons"] = function()
            require("mini.icons").mock_nvim_web_devicons()
            return package.loaded["nvim-web-devicons"]
        end
    end,
}
