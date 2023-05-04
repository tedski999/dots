vim.g.mapleader = " "

vim.g.border_type = "sharp"
vim.g.border_chars = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }

vim.g.altfile_map = {
	[".c"] = { ".h", ".hpp" },
	[".h"] = { ".c", ".cpp", ".cc" },
	[".cpp"] = { ".hpp", ".h" },
	[".hpp"] = { ".cpp", ".cc", ".c" },
	[".vert.glsl"] = { ".frag.glsl" },
	[".frag.glsl"] = { ".vert.glsl" }
}

-- TODO: steal and integrate a base46 theme

vim.g.arista =
	vim.loop.fs_stat("/usr/share/vim/vimfiles/arista.vim") and
	vim.fn.getcwd():find("^/src") ~= nil

if vim.g.arista then
	print("Note: Arista-specifics have been enabled for this Neovim instance")
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
	-- TODO: insert rather than overwrite
	vim.g.altfile_map = {
		[".c"] = { ".h", ".hpp", ".tac" },
		[".h"] = { ".c", ".cpp", ".cc", ".tin" },
		[".cpp"] = { ".hpp", ".h", ".tac" },
		[".hpp"] = { ".cpp", ".cc", ".c", ".tin" },
		[".vert.glsl"] = { ".frag.glsl" },
		[".frag.glsl"] = { ".vert.glsl" },
		[".tin"] = { ".tac", ".hpp", ".h" },
		[".tac"] = { ".tin", ".cpp", ".cc", ".c" },
	}
end
