-- Scrollbar
-- kinda slow, try: dstein64/nvim-scrollview petertriho/nvim-scrollbar
return {
	"lewis6991/satellite.nvim",
	event = "VeryLazy",
	enabled = false,
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
