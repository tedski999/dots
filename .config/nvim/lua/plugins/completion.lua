-- Autocompletion

local function normalise_string(str, max)
	str = (str or ""):match("[!-~].*[!-~]") or ""
	return #str > max
		and vim.fn.strcharpart(str, 0, max-1).."…"
		or str..(" "):rep(max-#str)
end

return {
	"echasnovski/mini.completion",
	version = "*",
	lazy = false,
	config = function()
		local mc = require("mini.completion")
		mc.setup({
			set_vim_settings = false,
			window = {
				info = { border = { " ", "", "", " " } },
				signature = { border = { " ", "", "", " " } },
			},
			lsp_completion = {
				process_items = function(items, base)
					items = mc.default_process_items(items, base)
					for _, item in ipairs(items) do
						item.label = normalise_string(item.label, 40)
						item.detail = normalise_string(item.detail, 10)
						item.additionalTextEdits = {}
					end
					return items
				end
			}
		})
	end
}
