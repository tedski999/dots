return {
	"m4xshen/smartcolumn.nvim",
	lazy = false,
	cond = vim.g.arista,
	opts = {
		colorcolumn = "86",
		disabled_filetypes = { "help", "text", "markdown" }
	}
}
