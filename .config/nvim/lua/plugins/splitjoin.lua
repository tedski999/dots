-- Quickly join and split lines
-- TODO: try AndrewRadev/splitjoin.vim
return {
	"echasnovski/mini.splitjoin",
	version = "*",
	keys = { "<leader>j", "<leader>J" },
	config = function()
		require("mini.splitjoin").setup({
			mappings = {
				toggle = "",
				join = "<leader>j",
				split = "<leader>J"
			}
		})
	end
}
