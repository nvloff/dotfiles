return {
    {
        -- Catppuccin is a community-driven pastel theme that aims to be the middle ground between
        -- low and high contrast themes. It consists of 4 soothing warm flavors with 26 eye-candy 
        -- colors each, perfect for coding, designing, and much more!
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            -- personally prefer black background in the terminal
            -- this just makes the background config a bit easier
            -- as it's only done in one place and can easily be disabled
            transparent_background = true,
            integrations = {
                mason = true,
                blink_cmp = true,
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
