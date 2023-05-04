return {
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
	build = ":TSUpdate",
	opts = {
		ensure_installed = {}, -- TODO: ts ensure_installed
		highlight = { enable = true },
		indent = { enable = true }
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end
}
