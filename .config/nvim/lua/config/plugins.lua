local path = vim.fn.stdpath("data").."/lazy/lazy.nvim"

-- Bootstrap lazy.nvim
if not vim.loop.fs_stat(path) then
	vim.api.nvim_echo({ { "Downloading lazy.nvim..." } }, false, {})
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim", "--branch=stable", path })
end

vim.opt.rtp:prepend(path)

require("lazy").setup("plugins", {
	defaults = { lazy = true },
	install = { colorscheme = { "carbonfox" } },
	change_detection = { enabled = false },
	lockfile = vim.fn.stdpath("config").."/lock.json",
	ui = {
		border = vim.g.border_chars,
		icons = {
			cmd = "cmd:", config = "cfg:", event = "evt:", ft = "ft:",
			init = "init:", keys = "key:", plugin = "plug:", runtime = "run:",
			source = "src:", start = "", task = "tsk:", lazy = "lzy:"
		}
	},
	performance = {
		rtp = {
			reset = false,
			disabled_plugins = {
				"2html_plugin", "tohtml", "getscript", "getscriptPlugin", "logipat",
				"matchit", "rrhelper", "spellfile_plugin", "tutor", "syntax",
				"synmenu", "optwin", "compiler", "bugreport", "ftplugin"
			}
		}
	}
})
