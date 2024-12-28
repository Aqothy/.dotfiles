return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeFindFileToggle", "NvimTreeToggle" },
    keys = {
        {
            "<leader>ee",
            "<cmd>NvimTreeToggle<CR>",
            desc = "Toggle file explorer",
        },
        {
            "<leader>ef",
            "<cmd>NvimTreeFindFileToggle<CR>",
            desc = "Toggle file explorer on current file",
        },
        {
            "<leader>ec", "<cmd>NvimTreeCollapse<CR>", desc = "Collapse file explorer"
        }
    },
    init = function()
        -- Custom lazy load for nvim-tree
        vim.api.nvim_create_autocmd("BufEnter", {
            group = vim.api.nvim_create_augroup("nvim-tree-start", { clear = true }),
            desc = "Start nvim-tree with a directory",
            once = true,
            callback = function()
                -- Check if nvim-tree is already loaded
                if package.loaded["nvim-tree"] then
                    return
                end

                -- Ensure there are arguments (argv) and check if the first argument is a directory
                local argv = vim.fn.argv(0)
                if argv and vim.uv.fs_stat(argv) and vim.uv.fs_stat(argv).type == "directory" then
                    require("nvim-tree").setup()
                    require("nvim-tree.api").tree.open()
                end
            end,
        })
    end,
    config = function()
        local nvimtree = require("nvim-tree")

        -- recommended settings from nvim-tree documentation
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        nvimtree.setup({
            view = {
                width = 30,
                relativenumber = true,
            },

            diagnostics = {
                enable = true,
            },

            -- disable window_picker for
            -- explorer to work well with
            -- window splits
            actions = {
                open_file = {
                    --					window_picker = {
                    --						enable = false,
                    --					},
                    --                    quit_on_open = true,
                },
            },
            filters = {
                custom = { ".DS_Store", "^.git$" },
                git_ignored = false,
            },
        })

        local prev = { new_name = "", old_name = "" } -- Prevents duplicate events
        vim.api.nvim_create_autocmd("User", {
            pattern = "NvimTreeSetup",
            callback = function()
                local events = require("nvim-tree.api").events
                events.subscribe(events.Event.NodeRenamed, function(data)
                    if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
                        data = data
                        Snacks.rename.on_rename_file(data.old_name, data.new_name)
                    end
                end)
            end,
        })
    end,
}
