return {
	{
		-- Catppuccin is a community-driven pastel theme that aims to be the middle ground between
		-- low and high contrast themes. It consists of 4 soothing warm flavors with 26 eye-candy
		-- colors each, perfect for coding, designing, and much more!
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				transparent_background = true,
				auto_integrations = true,
			})
			-- Load the colorscheme here.
			-- Like many other themes, this one has different styles, and you could load
			-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
}
