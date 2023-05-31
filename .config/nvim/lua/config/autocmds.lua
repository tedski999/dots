
-- Highlight suspicious whitespace
function get_whitespace_pattern()
	local pattern = [[[\u00a0\u1680\u180e\u2000-\u200b\u202f\u205f\u3000\ufeff]\+\|\s\+$\|[\u0020]\+\ze[\u0009]\+]]
	return "\\("..(vim.o.expandtab and pattern..[[\|^[\u0009]\+]] or pattern..[[\|^[\u0020]\+]]).."\\)"
end
function apply_whitespace_pattern(pattern)
	local disabled_ft = { diff=1, git=1, gitcommit=1, markdown=1, fugitive=1, lazy=1, undotree=1 }
	local disabled_bt = { quickfix=1, nofile=1, help=1, terminal=1 }
	local disabled = disabled_ft[vim.o.ft] or disabled_bt[vim.o.bt]
	if disabled then vim.cmd("match none") else vim.cmd("match ExtraWhitespace '"..pattern.."'") end
end
vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "TermOpen", "InsertLeave" }, { callback = function()
	apply_whitespace_pattern(get_whitespace_pattern())
end })
vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, { callback = function()
	local line, pattern = vim.fn.line("."), get_whitespace_pattern()
	apply_whitespace_pattern("\\%<"..line.."l"..pattern.."\\|\\%>"..line.."l"..pattern)
end })

-- If I can read it, I can edit it
vim.api.nvim_create_autocmd("BufEnter", { callback = function()
	vim.o.readonly = false
end })

-- Don't move cursor on yank
vim.api.nvim_create_autocmd("CursorMoved", { callback = function()
	vim.g.cursor_pos = vim.fn.getpos(".")
	vim.g.winview = vim.fn.winsaveview()
end })
vim.api.nvim_create_autocmd("TextYankPost", { callback = function()
	vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
	if vim.v.event.operator == "y" and vim.g.winview then
		vim.fn.setpos(".", vim.g.cursor_pos)
		vim.fn.winrestview(vim.g.winview)
	end
end })

-- Remember last cursor position
vim.api.nvim_create_autocmd("BufWinEnter", { callback = function()
	local disabled_filetypes = { diff=1, git=1, gitcommit=1, gitrebase=1, lazy=1 }
	local disabled_buftypes = { quickfix=1, nofile=1, help=1, terminal=1 }
	local disabled = disabled_filetypes[vim.o.ft] or disabled_buftypes[vim.o.buftype]
	if not (disabled or vim.fn.line(".") > 1 or vim.fn.line("'\"") <= 0 or vim.fn.line("'\"") > vim.fn.line("$")) then
		vim.cmd([[normal! g`"]])
	end
end })

-- Hide cursorline if not in current buffer
vim.api.nvim_create_autocmd({ "WinLeave", "FocusLost" }, { callback = function()
	vim.opt.cursorline, vim.opt.cursorcolumn = false, false
end })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "FocusGained" }, { callback = function()
	vim.opt.cursorline, vim.opt.cursorcolumn = true, true
end })

-- Keep universal formatoptions
vim.api.nvim_create_autocmd("Filetype", { callback = function() vim.o.formatoptions = "rqlj" end })

-- Swap to manual folding
vim.api.nvim_create_autocmd("BufWinEnter", { callback = function() vim.o.foldmethod = "manual" end })
