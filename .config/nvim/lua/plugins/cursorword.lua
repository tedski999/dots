return {
	"xiyaowong/nvim-cursorword",
	event = "CursorMoved",
	config = function()
		vim.g.cursorword_disable_filetypes = {}
		vim.g.cursorword_disable_at_startup = false
		vim.g.cursorword_min_width = 1
		vim.g.cursorword_max_width = 50
	end
}
