vim.cmd [[
  aunmenu PopUp
  anoremenu PopUp.Inspect     <cmd>Inspect<CR>
  anoremenu PopUp.Definition  <cmd>lua require('fzf-lua').lsp_definitions()<CR>
  anoremenu PopUp.References  <cmd>lua require('fzf-lua').lsp_references()<CR>
]]

local group = vim.api.nvim_create_augroup("nvim_popupmenu", { clear = true })
vim.api.nvim_create_autocmd("MenuPopup", {
    pattern = "*",
    group = group,
    desc = "Custom PopUp Setup",
    callback = function()
        vim.cmd [[
      amenu disable PopUp.Definition
      amenu disable PopUp.References
    ]]

        if vim.lsp.get_clients({ bufnr = 0 })[1] then
            vim.cmd [[
        amenu enable PopUp.Definition
        amenu enable PopUp.References
      ]]
        end
    end,
})
