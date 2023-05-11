-- Highlight matching words under cursor
return {
	"xiyaowong/nvim-cursorword",
	event = "CursorMoved",
	config = function() vim.g.cursorword_min_width = 1 end
}
