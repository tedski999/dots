vim.g.mapleader = " "

-- Consistent aesthetics
vim.g.border_type = "sharp"
vim.g.border_chars = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
vim.lsp.protocol.CompletionItemKind = {
	'""', ".f", "fn", "()", ".x",
	"xy", "{}", "{}", "[]", ".p",
	"$$", "00", "∀e", ";;", "~~",
	"rg", "/.", "&x", "//", "∃e",
	"#x", "{}", "ev", "++", "<>"
}

-- Provide method to apply ftplugin and syntax settings to all filetypes
vim.g.myfiletypefile = vim.fn.stdpath("config").."/ftplugin/ftplugin.vim"
vim.g.mysyntaxfile = vim.fn.stdpath("config").."/syntax/syntax.vim"

-- Quickly switch between alternative files by extensions
vim.g.altfile_map = {
	[".c"] = { ".h", ".hpp" },
	[".h"] = { ".c", ".cpp" },
	[".cpp"] = { ".hpp", ".h" },
	[".hpp"] = { ".cpp", ".c" },
	[".vert.glsl"] = { ".frag.glsl" },
	[".frag.glsl"] = { ".vert.glsl" }
}

-- -- Get full path of path or current buffer
vim.g.getfile = function(path)
	return vim.fn.fnamemodify(path or vim.api.nvim_buf_get_name(0), ":p")
end

-- Disable some providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Is this an Arista environment?
vim.g.arista = vim.loop.fs_stat("/usr/share/vim/vimfiles/arista.vim") and vim.fn.getcwd():find("^/src") ~= nil
if vim.g.arista then
	vim.api.nvim_echo({ { "Note: Arista-specifics have been enabled for this Neovim instance", "MoreMsg" } }, false, {})

	-- Always rooted at /src
	vim.fn.chdir("/src")

	-- Source arista.vim but override A4edit and A4revert
	vim.cmd([[
		let g:a4_auto_edit = 0
		source /usr/share/vim/vimfiles/arista.vim
		function! A4edit()
			if strlen(glob(expand('%')))
				belowright split
				exec 'terminal a p4 login && a p4 edit '.shellescape(expand('%:p'))
				set noreadonly
			endif
		endfunction
		function! A4revert()
			if strlen(glob(expand('%'))) && confirm('Revert Perforce file changes?', '&Yes\n&No', 1) == 1
				exec 'terminal a p4 login && a p4 revert '.shellescape(expand('%:p'))
				set readonly
			endif
		endfunction
	]])
	vim.api.nvim_create_user_command("Aedit", "call A4edit()", {})
	vim.api.nvim_create_user_command("Arevert", "call A4revert()", {})

	-- Add .tac and .tin to altfiles
	local altfile_map = vim.g.altfile_map or {}
	altfile_map[".tac"] = { ".tin", ".cpp", ".c" }
	altfile_map[".tin"] = { ".tac", ".hpp", ".h" }
	table.insert(altfile_map[".c"], ".tac")
	table.insert(altfile_map[".h"], ".tin")
	table.insert(altfile_map[".cpp"], ".tac")
	table.insert(altfile_map[".hpp"], ".tin")
	vim.g.altfile_map = altfile_map
end
