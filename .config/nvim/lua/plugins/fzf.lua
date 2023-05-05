-- TODO(fzf): yank result as an action
-- TODO(fzf): fzf file explorer/manager? see advanced wiki

function find_altfiles()
	-- TODO(alt): relative to file
	fzf = require("fzf-lua")
	local file = vim.fn.expand("%:p:~:.")
	local possible, existing = {}, {}
	for key, exts in pairs(vim.g.altfile_map) do
		if file:sub(-#key) == key then
			for _, ext in ipairs(exts) do
				altfile = file:sub(1, -#key-1)..ext
				table.insert(possible, altfile)
				if vim.loop.fs_stat(altfile) then
					table.insert(existing, altfile)
				end
			end
		end
	end
	if #existing == 1 then
		vim.cmd("edit "..existing[1])
	elseif #existing ~= 0 then
		fzf.fzf_exec(existing, { actions = fzf.defaults.actions.files, previewer = "builtin" })
	elseif #possible ~= 0 then
		fzf.fzf_exec(possible, { actions = fzf.defaults.actions.files, fzf_opts = { ["--header"] = [["No configured altfiles found"]]  } })
	else
		vim.api.nvim_echo({ { "Error: No altfiles configured", "Error" } }, false, {})
	end
end

return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	keys = {
		{ "z=", "<cmd>FzfLua spell_suggest<cr>" },
		{ "<leader>b", "<cmd>FzfLua buffers cwd=%:p:h<cr>" },
		{ "<leader>B", "<cmd>FzfLua buffers<cr>" },
		{ "<leader>l", "<cmd>FzfLua blines<cr>" },
		{ "<leader>f", "<cmd>FzfLua files cwd=%:p:h<cr>" },
		{ "<leader>F", "<cmd>FzfLua files<cr>" },
		{ "<leader>s", "<cmd>FzfLua grep_project cwd=%:p:h<cr>" },
		{ "<leader>S", "<cmd>FzfLua grep_project<cr>" },
		{ "<leader>h", "<cmd>FzfLua help_tags prompt=>\\ <cr>" },
		{ "<leader>H", "<cmd>FzfLua man_pages prompt=>\\ <cr>" },
		{ "<leader>o", "<cmd>FzfLua oldfiles cwd_only=true<cr>" },
		{ "<leader>O", "<cmd>FzfLua oldfiles<cr>" },
		{ "<leader>E", "<cmd>FzfLua diagnostics_document<cr>" },
		{ "<leader>gg", "<cmd>FzfLua git_status<cr>" },
		{ "<leader>gl", "<cmd>FzfLua git_bcommits<cr>" },
		{ "<leader>gL", "<cmd>FzfLua git_commits<cr>" },
		{ "<leader>gb", "<cmd>FzfLua git_branches<cr>" },
		{ "<leader>d", "<cmd>FzfLua lsp_definitions<cr>" },
		-- TODO(fzf): previewer currently broken
		-- { "<leader>r", "<cmd>FzfLua lsp_finder<cr>" },
		{ "<leader>r", "<cmd>FzfLua lsp_references<cr>" },
		{ "<leader>c", "<cmd>FzfLua quickfix<cr>" },
		{ "<leader>C", "<cmd>FzfLua quickfix_stack<cr>" },
		{ "<leader>a", find_altfiles },
	},
	config = function()
		fzf = require("fzf-lua")
		fzf.setup({
			winopts = {
				height = 0.9,
				width = 0.9,
				row = 0.2,
				col = 0.5,
				border = vim.g.border_chars,
				-- TODO(aesthetic): fix colorscheme FloatBorder
				hl = { normal = "Normal", border = "FloatBorder" }
			},
			global_file_icons = false,
			global_git_icons = false,
			global_color_icons = false,
			keymap = { builtin = { ["<c-_>"] = "toggle-preview" } },
			previewers = { man = { cmd = "man %s | col -bx" } },
			files = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			grep = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false, no_header = true },
			oldfiles = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false, stat_file = false, include_current_session = true },
			buffers = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			tabs = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			lines = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			blines = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			quickfix = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			quickfix_stack = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false, marker = "<" },
			diagnostics = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			git = {
				status = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				commits = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				bcommits = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				branches = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				stash = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false }
			},
			lsp = {
				prompt_postfix = "> ",
				file_icons = false,
				code_actions = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				finder = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false, async = false, separator = " " }
			}
		})
		if vim.g.arista then
			vim.api.nvim_create_user_command("Achanged", function() fzf.fzf_exec("a p4 diff --summary | sed s/^/\\//", { previewer = "builtin" }) end, {})
			vim.api.nvim_create_user_command("Aopened",  "let o = system('a p4 opened') | if o != '' | echo o | else | echo 'Nothing opened' | endif", {})
			vim.api.nvim_create_user_command("Agid",  function() fzf.fzf_exec("a grok -em 99", { previewer = "builtin" }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("AgidP", function() fzf.fzf_exec("a grok -em 99 -f "..(vim.api.nvim_buf_get_name(0):match("^/.-/.-/") or "/"), { previewer = "builtin" }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
			vim.api.nvim_create_user_command("Agid",  function() fzf.fzf_exec("a ws gid -cq", { previewer = "builtin" }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("AgidP", function() fzf.fzf_exec("a ws gid -cqp "..(vim.api.nvim_buf_get_name(0):match("^/.-/(.-)/") or "/"), { previewer = "builtin" }) end, { nargs = 1 })
			vim.keymap.set("n", "<leader>r", "<cmd>AgidP    "..vim.fn.expand("<cword>").."<cr>")
			vim.keymap.set("n", "<leader>R", "<cmd>Agid     "..vim.fn.expand("<cword>").."<cr>")
			vim.keymap.set("n", "<leader>d", "<cmd>AgidP -D "..vim.fn.expand("<cword>").."<cr>")
			vim.keymap.set("n", "<leader>D", "<cmd>Agid  -D "..vim.fn.expand("<cword>").."<cr>")
		end
	end
}
