local command = vim.api.nvim_create_user_command

command("Tsc", function()
    vim.cmd("compiler tsc | echo 'Building TypeScript...' | silent make | echo 'TypeScript built.' | copen")
end, { desc = "Typescript type check", nargs = 0 })
