vim.g.mapleader = " "

vim.g.border_type = "sharp"
vim.g.border_chars = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }

vim.g.altfile_map = {
	[".c"] = { ".h", ".hpp" },
	[".h"] = { ".c", ".cpp" },
	[".cpp"] = { ".hpp", ".h" },
	[".hpp"] = { ".cpp", ".c" },
	[".vert.glsl"] = { ".frag.glsl" },
	[".frag.glsl"] = { ".vert.glsl" }
}

-- TODO(aesthetic): steal and integrate a base46 theme

vim.g.arista =
	vim.loop.fs_stat("/usr/share/vim/vimfiles/arista.vim") and
	vim.fn.getcwd():find("^/src") ~= nil

if vim.g.arista then
	vim.api.nvim_echo({ { "Note: Arista-specifics have been enabled for this Neovim instance", "MoreMsg" } }, false, {})

	vim.cmd([[
		chdir /src
		let a4_auto_edit = 0
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
	vim.api.nvim_create_user_command("Aedit", "A4edit", {})
	vim.api.nvim_create_user_command("Arevert", "A4revert", {})

	local altfile_map = vim.g.altfile_map or {}
	altfile_map[".tac"] = { ".tin", ".cpp", ".c" }
	altfile_map[".tin"] = { ".tac", ".hpp", ".h" }
	table.insert(altfile_map[".c"], ".tac")
	table.insert(altfile_map[".h"], ".tin")
	table.insert(altfile_map[".cpp"], ".tac")
	table.insert(altfile_map[".hpp"], ".tin")
	vim.g.altfile_map = altfile_map
end
