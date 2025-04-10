vim.api.nvim_create_user_command("Ns", "silent !tmux neww ts.sh", { desc = "New tmux session" })
