return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            integrations = {
                mason = true,
                cmp = true,
                gitsigns = true,
                indent_blankline = { enabled = true },
                lsp_trouble = true,
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = { "undercurl" },
                        hints = { "undercurl" },
                        warnings = { "undercurl" },
                        information = { "undercurl" },
                    },
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                    },
                },
                neotest = true,
                telescope = true,
                treesitter = true,
                which_key = true,
                neotree = true,
            },
        },
    },
}
