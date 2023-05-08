-- TODO(next): try rebelot/heirline.nvim
return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = "EdenEast/nightfox.nvim",
	config = function()
		local p = require("nightfox.palette").load("carbonfox")
		require("lualine").setup({
			options = {
				icons_enabled = false,
				section_separators = "",
				component_separators = "",
				refresh = { statusline = 100, tabline = 100, winbar = 100 },
				theme = {
					normal =   { a = { bg = p.black.bright, fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
					insert =   { a = { bg = p.green.base,   fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
					visual =   { a = { bg = p.magenta.dim,  fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
					replace =  { a = { bg = p.red.base,     fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
					command =  { a = { bg = p.black.bright, fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
					terminal = { a = { bg = p.bg0,          fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
					inactive = { a = { bg = p.bg2,          fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
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
		})
	end
}
