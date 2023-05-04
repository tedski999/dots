return {
	"kylechui/nvim-surround",
	version = "*",
	opts = { move_cursor = false },
	keys = {
		"ys", "yS", "ds", "cs",
		{ "<c-g>s", nil, mode = "i" },
		{ "<c-g>S", nil, mode = "i" },
		{ "S", nil, mode = "v" },
		{ "gS", nil, mode = "v" }
	}
}
