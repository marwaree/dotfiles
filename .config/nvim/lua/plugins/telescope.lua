return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    event = "VimEnter",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    config = function()
        local builtin = require("telescope.builtin")
        local telescope = require("telescope")

        telescope.setup {
            defaults = {
                file_ignore_patterns = {
                    "%.jpg$",
                    "%.png$",
                    "%.gif$",
                    "%.webp$",
                    "%.ico$",
                    "%.pdf$",
                    "%.zip$",
                    "%.tar$",
                    "%.gz$",
                    "%.mp4$",
                    "%.mp3$",
                    "%.wav$",
                    "%.woff$",
                    "%.woff2$",
                    "%.ttf$",
                    "node_modules",
                    "__pycache__",
                    ".git/",
                },
            },
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {},
                },
                fzf = {},
            },
        }

        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("fzf") -- Recommended if using fzf-native

        -- Keymaps
        vim.keymap.set("n", "<leader>ff", builtin.find_files)
        vim.keymap.set({ "n", "v" }, "<leader>fw", builtin.grep_string)
        vim.keymap.set("n", "<leader>fg", builtin.live_grep)
        vim.keymap.set("n", "<leader>fd", builtin.diagnostics)
        vim.keymap.set("n", "<leader>fb", builtin.buffers)

        -- Search neovim config
        vim.keymap.set("n", "<leader>fn", function() builtin.find_files { cwd = vim.fn.stdpath("config"), follow = true } end)
    end,
}
