local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}
