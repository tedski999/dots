return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			config = function()
				require("luasnip").config.set_config({})
			end,
		},
		{
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline"
		}
	},
	config = function()
		-- TODO(next): cmp config
		local cmp = require("cmp")
		local cmpmap = {
			["<c-j>"] = cmp.mapping(cmp.mapping.confirm({select=true}), { 'i', 's', 'c' }),
			["<c-n>"] = cmp.mapping(function() if not cmp.select_next_item() then cmp.complete() end end, { 'i', 's', 'c' }),
			["<c-p>"] = cmp.mapping(function() if not cmp.select_prev_item() then cmp.complete() end end, { 'i', 's', 'c' }),
			["<c-d>"] = cmp.mapping.scroll_docs(-4),
			["<c-f>"] = cmp.mapping.scroll_docs(4),
		}
		cmp.setup({
			mapping = cmpmap,
			sources = cmp.config.sources({{name="nvim_lsp"},{name="luasnip"}},{{name="path"},{name="buffer"}}),
			snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
			view = { entries = { name = "custom", selection_order = "near_cursor" } },
			completion = { completeopt = "menu,menuone,preview" },
			experimental = { ghost_text = true },
			formatting = {
				format = function(_, item)
					item.abbr = #item.abbr > 50 and vim.fn.strcharpart(item.abbr, 0, 49)..'…' or item.abbr..(' '):rep(50-#item.abbr)
					item.kind = ({
						Text = '""',     Method = '.f', Function = 'fn',  Constructor = '()', Field = '.x',
						Variable = 'xy', Class = '{}',  Interface = '{}', Module = '[]',      Property = '.p',
						Unit = '$$',     Value = '00',  Enum = '∀e',      Keyword = ';;',     Snippet = '~~',
						Color = 'rgb',   File = '/.',   Reference = '&x', Folder = '//',      EnumMember = '∃e',
						Constant = '#x', Struct = '{}', Event = 'ev',     Operator = '++',    TypeParameter = '<>'
					})[item.kind]
					return item
				end
			}
			-- window = {
				-- completion = {
					-- side_padding = (cmp_style ~= "atom" and cmp_style ~= "atom_colored") and 1 or 0,
					-- winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel",
					-- scrollbar = false,
				-- },
				-- documentation = {
					-- border = vim.g.border_chars,
					-- winhighlight = "Normal:CmpDoc",
				-- },
			-- },
		})
		-- highlight CmpItemAbbrMatch gui=bold guifg=#569cd6
	end
}
