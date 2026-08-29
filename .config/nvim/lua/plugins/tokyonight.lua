local function gh(repo) return 'https://github.com/' .. repo end

  vim.pack.add { gh 'folke/tokyonight.nvim' }
  ---@diagnostic disable-next-line: missing-fields
  require('tokyonight').setup {
    transparent = true,
  }
