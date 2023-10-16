local highlight = {
    "CursorColumn",
    "Whitespace",
}

require("ibl").setup {
    indent = { tab_char = "┊" },
    whitespace = {
        highlight = highlight,
        remove_blankline_trail = false,
    },
    scope = { enabled = true },
}
