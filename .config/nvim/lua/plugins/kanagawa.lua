return {
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        opts = {
            colors = {
                theme = {
                    all = {
                        ui = {
                            bg_gutter = "none",
                        },
                    },
                },
            },
            overrides = function(colors)
                local theme = colors.theme
                return {
                    Normal = { bg = "none" },
                    TelescopeNormal = { bg = theme.ui.bg_m1 },
                    TelescopeResultsNormal = { bg = theme.ui.bg_m1 },
                    TelescopePromptNormal = { bg = theme.ui.bg_m1 },
                    TelescopeBorder = { bg = theme.ui.bg_m1 },
                    TelescopeResultsBorder = { bg = theme.ui.bg_m1 },
                    TelescopePromptBorder = { bg = theme.ui.bg_m1 },
                }
            end,
        },
    },
}
