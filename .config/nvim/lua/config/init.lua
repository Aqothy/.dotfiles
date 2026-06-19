local disabled_plugins = {
    "gzip",
    "tarPlugin",
    "tohtml",
    "tutor",
    "zipPlugin",
    "netrwPlugin",
}

for _, plugin in ipairs(disabled_plugins) do
    vim.g["loaded_" .. plugin] = 1
end

local imports = { "plugins" }
local cond

if vim.g.vscode then
    table.insert(imports, "config.vscode")

    local vscode_plugins = {
        "nvim-surround",
        "nvim-treesitter",
        "nvim-treesitter-textobjects",
        "flash.nvim",
        "treesj",
        "mini.ai",
        "blink.indent",
        "multicursor.nvim",
        "mini.operators",
        "nvim-spider",
        "vim-test",
    }

    cond = function(plugin)
        return vim.tbl_contains(vscode_plugins, plugin.name)
    end
end

require("custom.pack").setup({
    imports = imports,
    cond = cond,
})
