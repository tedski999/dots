return {
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash", "c", "cmake", "comment", "cpp",
			"css", "dockerfile", "fish", "glsl", "go",
			"html", "java", "javascript", "jsdoc", "json",
			"latex", "lua", "make", "python", "rust",
			"scss", "toml", "typescript", "vim", "yaml"
		},
		highlight = { enable = true },
		indent = { enable = true }
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end
}
