-- Scrollbar
return {
	"lewis6991/satellite.nvim",
	event = "VeryLazy",
	opts = {
		winblend = 0,
		handlers = {
			search = { enable = true },
			diagnostic = { enable = true },
			gitsigns = { enable = false },
			marks = { enable = false }
		}
	}
}
