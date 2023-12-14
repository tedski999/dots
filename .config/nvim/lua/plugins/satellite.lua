-- Scrollbar
-- TODO: patch for nightly
return {
	"lewis6991/satellite.nvim",
	event = "VeryLazy",
	opts = {
		winblend = 0,
		handlers = {
			cursor = { enable = true, symbols = { '⎺', '⎻', '—', '⎼', '⎽' } },
			search = { enable = true },
			diagnostic = { enable = true, min_severity = vim.diagnostic.severity.WARN },
			gitsigns = { enable = false },
			marks = { enable = false }
		}
	}
}
