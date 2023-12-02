local km = vim.keymap.set
local uc = vim.api.nvim_create_user_command

-- Return the alphabetically previous and next files
local function prev_and_next_file(file)
	file = (file or vim.g.getfile()):gsub("/$", "")
	local prev, dir = file, file:match(".*/") or "/"
	local files = (vim.fn.glob(dir..".[^.]*").."\n"..vim.fn.glob(dir.."*")):gmatch("[^\n]+")
	for next in files do
		if next == file then return prev, files() or next
		elseif next > file then return prev, next
		else prev = next end
	end
	return prev, file
end

km("n", "<leader>", "")
-- Don't jump over wrapped lines
km({ "n", "v" }, "j", "gj")
km({ "n", "v" }, "k", "gk")
-- Handy buffer shortcuts
uc("W", ":w !>/dev/null sudo tee %", {})
-- Split lines at cursor, opposite of <s-j>
km("n", "<c-j>", "m`i<cr><esc>``")
-- Terminal shortcuts
km("n", "<leader><return>", "<cmd>belowright split | terminal<cr>")
km("t", "<esc>", "(&filetype == 'fzf') ? '<esc>' : '<c-\\><c-n>'", { expr = true })
-- Open config
km("n", "<leader>;", "<cmd>edit "..vim.fn.stdpath("config").."<cr>")
km("n", "<leader>:", "<cmd>edit "..vim.fn.stdpath("data").."<cr>")
-- Open notes
km("n", "<leader>n", "<cmd>lcd ~/Documents/notes | enew | set filetype=markdown<cr>")
km("n", "<leader>N", "<cmd>lcd ~/Documents/notes | edit `=strftime('./journal/%Y/%V.md')` | call mkdir(expand('%:h'), 'p')<cr>")
-- LSP
km("n", "<leader><leader>", "<cmd>lua vim.lsp.buf.hover()<cr>")
km("n", "<leader>k",        "<cmd>lua vim.lsp.buf.code_action()<cr>")
km("n", "]e",               "<cmd>lua vim.diagnostic.goto_next()<cr>")
km("n", "[e",               "<cmd>lua vim.diagnostic.goto_prev()<cr>")
km("n", "<leader>e",        "<cmd>lua vim.diagnostic.open_float()<cr>")
km("n", "<leader>E",        "<cmd>lua vim.diagnostic.setqflist()<cr>")
km("n", "<leader>d",        "<cmd>lua vim.lsp.buf.definition()<cr>")
km("n", "<leader>t",        "<cmd>lua vim.lsp.buf.type_definition()<cr>")
km("n", "<leader>r",        "<cmd>lua vim.lsp.buf.references()<cr>")
-- Buffers
km("n", "[b", "<cmd>bprevious<cr>")
km("n", "]b", "<cmd>bnext<cr>")
km("n", "[B", "<cmd>bfirst<cr>")
km("n", "]B", "<cmd>blast<cr>")
-- Files
km("n", "[f", function() vim.cmd("edit "..select(1, prev_and_next_file())) end)
km("n", "]f", function() vim.cmd("edit "..select(2, prev_and_next_file())) end)
km("n", "[F", function() local cur, old = vim.g.getfile(); while cur ~= old do old = cur; cur, _ = prev_and_next_file(cur) end vim.cmd("edit "..cur) end)
km("n", "]F", function() local cur, old = vim.g.getfile(); while cur ~= old do old = cur; _, cur = prev_and_next_file(cur) end vim.cmd("edit "..cur) end)
-- Quickfix
km("n", "[c", "<cmd>cprevious<cr>")
km("n", "]c", "<cmd>cnext<cr>")
km("n", "[C", "<cmd>cfirst<cr>")
km("n", "]C", "<cmd>clast<cr>")
-- Toggles
km("n", "yo", "")
km("n", "yot", "<cmd>set expandtab! expandtab?<cr>")
km("n", "yow", "<cmd>set wrap! wrap?<cr>")
km("n", "yon", "<cmd>set number! number?<cr>")
km("n", "yor", "<cmd>set relativenumber! relativenumber?<cr>")
km("n", "yoi", "<cmd>set ignorecase! ignorecase?<cr>")
km("n", "yol", "<cmd>set list! list?<cr>")
km("n", "yoz", "<cmd>set spell! spell?<cr>")
