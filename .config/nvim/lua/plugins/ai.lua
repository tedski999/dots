return {
	"echasnovski/mini.ai",
	version = "*",
	keys = {
		{ "a", nil, mode = { "n", "v" } },
		{ "i", nil, mode = { "n", "v" } },
		{ "g[", nil, mode = { "n", "v" } },
		{ "g]", nil, mode = { "n", "v" } }
	},
	config = function()
		require("mini.ai").setup({ n_lines = 999 })
	end
}
