local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/todo-comments.nvim' }
require('todo-comments').setup { signs = false }
