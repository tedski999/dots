local km = vim.keymap.set

local function prev_and_next_file(file)
	if file == "" then return ".", "." end
	local prev, dir = file, file:match(".*/")
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
km("n", "<leader>w", "<cmd>w<cr>",  { nowait = true })
km("n", "<leader>W", "<cmd>wq<cr>", { nowait = true })
km("n", "<leader>q", "<cmd>q<cr>",  { nowait = true })
km("n", "<leader>Q", "<cmd>qa<cr>", { nowait = true })
-- Split lines at cursor, opposite of <s-j>
km("n", "<c-j>", "m`i<cr><esc>``")
-- Terminal shortcuts
km("n", "<leader><return>", "<cmd>belowright split | exec 'terminal' | startinsert<cr>")
km("t", "<esc>", "(&filetype == 'fzf') ? '<esc>' : '<c-\\><c-n>'", { expr = true })
-- Disable cmdline tab completion
km("c", "<tab>", "<tab>")
km("c", "<s-tab>", "<s-tab>")
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
km("n", "[f", function() file, _ = prev_and_next_file(vim.api.nvim_buf_get_name(0)); vim.cmd("edit "..file) end)
km("n", "]f", function() _, file = prev_and_next_file(vim.api.nvim_buf_get_name(0)); vim.cmd("edit "..file) end)
km("n", "[F", function() local cur, old = vim.api.nvim_buf_get_name(0); while cur ~= old do old = cur; cur, _ = prev_and_next_file(cur) end vim.cmd("edit "..cur) end)
km("n", "]F", function() local cur, old = vim.api.nvim_buf_get_name(0); while cur ~= old do old = cur; _, cur = prev_and_next_file(cur) end vim.cmd("edit "..cur) end)
-- Quickfix
km("n", "[q", "<cmd>cprevious<cr>")
km("n", "]q", "<cmd>cnext<cr>")
km("n", "[Q", "<cmd>cfirst<cr>")
km("n", "]Q", "<cmd>clast<cr>")
-- Toggles
km("n", "yo", "")
km("n", "yot", "<cmd>set expandtab! expandtab?<cr>")
km("n", "yow", "<cmd>set wrap! wrap?<cr>")
km("n", "yon", "<cmd>set number! number?<cr>")
km("n", "yor", "<cmd>set relativenumber! relativenumber?<cr>")
km("n", "yoi", "<cmd>set ignorecase! ignorecase?<cr>")
km("n", "yol", "<cmd>set list! list?<cr>")
km("n", "yoz", "<cmd>set spell! spell?<cr>")
-- Git
vim.api.nvim_create_user_command("Gcommit", "belowright split | exec 'terminal git commit <args>' | startinsert", { nargs = "*" })
vim.api.nvim_create_user_command("Gpull", "belowright split | terminal echo 'Pulling...' && git pull <args>", { nargs = "*" })
vim.api.nvim_create_user_command("Gpush", "belowright split | terminal echo 'Pushing...' && git push <args>", { nargs = "*" })
km("n", "<leader>gc", "<cmd>Gcommit<cr>")
km("n", "<leader>gp", "<cmd>Gpull<cr>")
km("n", "<leader>gP", "<cmd>Gpush<cr>")
