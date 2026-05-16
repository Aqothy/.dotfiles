vim.opt_local.spell = true
vim.keymap.set(
    "n",
    "<localleader>mp",
    require("custom.markdown_preview").toggle,
    { buf = 0, desc = "Markdown Preview" }
)
