-- Git integration
return {
	"tpope/vim-fugitive",
	event = "VeryLazy",
	keys = {
		-- TODO(vcs) undo hunk/file, stage hunk/file, unstage hunk/file
	},
	config = function()
		-- TODO(vcs): learn fugitive
	end
}
