require("aqothy.config.options")
vim.filetype.add({
    filename = {
        [".env"] = "dotenv",
    },
    pattern = {
        [".*/kitty/.+%.conf"] = "kitty",
        ["%.env%.[%w_.-]+"] = "dotenv",
    },
})

require("aqothy.config")

require("aqothy.config.autocmds")
require("aqothy.config.keymaps")
require("aqothy.config.commands")

require("vim._extui").enable({})
