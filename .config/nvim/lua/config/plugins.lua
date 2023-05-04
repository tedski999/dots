local path = vim.fn.stdpath("data").."/lazy/lazy.nvim"
vim.opt.rtp:prepend(path)

if not vim.loop.fs_stat(path) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim", "--branch=stable", path })
end

require("lazy").setup("plugins", {
	defaults = { lazy = true },
	install = { colorscheme = { "gotham" } },
	change_detection = { enabled = false },
	lockfile = vim.fn.stdpath("data").."/lazy/lock.json",
	ui = {
		border = vim.g.border_chars,
		icons = { -- TODO(aesthetic): icons and theming
			cmd = "?", config = "?", event = "?", ft = "?",
			init = "?", keys = "?", plugin = "?", runtime = "?",
			source = "?", start = "?", task = "?", lazy = "?"
		}
	},
	performance = { rtp = { disabled_plugins = {
		"2html_plugin", "tohtml", "getscript", "getscriptPlugin",
		"logipat", "matchit", "rrhelper", "spellfile_plugin",
		"tutor", "rplugin", "syntax", "synmenu",
		"optwin", "compiler", "bugreport", "ftplugin",
	} } }
})
