local km = vim.keymap.set

-- Don't jump over wrapped lines
km({ "n", "v" }, "j", "gj")
km({ "n", "v" }, "k", "gk")
-- Handy buffer shortcuts
km("n", "<leader>w", "<cmd>w<cr>",  { nowait = true })
km("n", "<leader>W", "<cmd>wq<cr>", { nowait = true })
km("n", "<leader>q", "<cmd>q<cr>",  { nowait = true })
km("n", "<leader>Q", "<cmd>q!<cr>", { nowait = true })
-- Split lines at cursor, opposite of <s-j>
km("n", "<c-j>", "m`i<cr><esc>``")
-- Terminal shortcuts
km("n", "<leader><return>", "<cmd>exec 'terminal' | startinsert<cr>")
km("t", "<esc>", "(&filetype == 'fzf') ? '<esc>' : '<c-\\><c-n>'", { expr = true })
-- Disable cmdline tab completion
km("c", "<tab>", "<tab>")
km("c", "<s-tab>", "<s-tab>")
-- Open config
km("n", "<leader>c", "<cmd>edit "..vim.fn.stdpath("config").."<cr>")
km("n", "<leader>C", "<cmd>edit "..vim.fn.stdpath("data").."<cr>")
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
km("n", "<leader>f",        "<esc><cmd>lua vim.lsp.buf.range_formatting()<cr>")
