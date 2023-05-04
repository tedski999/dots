return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	opts = {
		options = {
			icons_enabled = false,
			section_separators = "",
			component_separators = "",
			refresh = { statusline = 100, tabline = 100, winbar = 100 },
			theme = { -- TODO(aesthetic): write lualine theme using globals
				normal =   {a={bg="#195466", fg="#d3ebe9", gui="bold"}, b={bg="#0a3749", fg="#99d1ce"}, c={bg="#111a23", fg="#599cab"}},
				insert =   {a={bg="#009368", fg="#d3ebe9", gui="bold"}, b={bg="#0a3749", fg="#99d1ce"}, c={bg="#111a23", fg="#599cab"}},
				visual =   {a={bg="#cb6635", fg="#d3ebe9", gui="bold"}, b={bg="#0a3749", fg="#99d1ce"}, c={bg="#111a23", fg="#599cab"}},
				replace =  {a={bg="#c23127", fg="#d3ebe9", gui="bold"}, b={bg="#0a3749", fg="#99d1ce"}, c={bg="#111a23", fg="#599cab"}},
				command =  {a={bg="#62477c", fg="#d3ebe9", gui="bold"}, b={bg="#0a3749", fg="#99d1ce"}, c={bg="#111a23", fg="#599cab"}},
				terminal = {a={bg="#111a23", fg="#d3ebe9", gui="bold"}, b={bg="#0a3749", fg="#99d1ce"}, c={bg="#111a23", fg="#599cab"}},
				inactive = {a={bg="#111a23", fg="#d3ebe9", gui="bold"}, b={bg="#0a3749", fg="#99d1ce"}, c={bg="#111a23", fg="#599cab"}}
			}
		},
		sections = {
			lualine_a = {{"mode", fmt = function(m) return m:sub(1,1) end}},
			lualine_b = {{"filename", symbols={modified="*", readonly="-"}}},
			lualine_c = {"diff"},
			lualine_x = {{"diagnostics", sections={"error", "warn"}}},
			lualine_y = {"filetype"},
			lualine_z = {"progress", "location"},
		},
		inactive_sections = {
			lualine_a = {{"mode", fmt=function() return " " end}},
			lualine_b = {},
			lualine_c = {{"filename", symbols={modified="*", readonly="-"}}, "diff"},
			lualine_x = {{"diagnostics", sections={"error", "warn"}}},
			lualine_y = {},
			lualine_z = {}
		}
	}
}
