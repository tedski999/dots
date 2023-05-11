-- Hide colorcolumn unless passed
return {
	"m4xshen/smartcolumn.nvim",
	lazy = false,
	cond = vim.g.arista,
	opts = {
		colorcolumn = "85",
		disabled_filetypes = { "help", "text", "markdown" }
	}
}
