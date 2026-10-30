return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    opts = {
        linters_by_ft = {
            markdown = { "markdownlint-cli2" },
        },
        linters = {
            ["markdownlint-cli2"] = {
                args = function()
                    local root = vim.fn.getcwd()
                    local cfg = root .. "/.markdownlint.json"
                    if vim.fn.filereadable(cfg) == 1 then return { "--config", cfg, "--" } end
                    return {}
                end,
            },
        },
    },
    config = function(_, opts)
        local lint = require("lint")

        for name, linter in pairs(opts.linters or {}) do
            if type(linter) == "table" and type(lint.linters[name]) == "table" then
                lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
            else
                lint.linters[name] = linter
            end
        end

        lint.linters_by_ft = opts.linters_by_ft

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = vim.api.nvim_create_augroup("lint", { clear = true }),
            callback = function()
                if vim.bo.modifiable then lint.try_lint() end
            end,
        })
    end,
}
