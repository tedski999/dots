return {
	"tommcdo/vim-lion",
	config = function() vim.g.lion_squeeze_spaces = 1 end,
	keys = {
		{ "gl", nil, mode = "v" },
		{ "gL", nil, mode = "v" }
	}
}
