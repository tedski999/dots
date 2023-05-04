-- TODO: replace with scroll bar
return {
	"gorbit99/codewindow.nvim",
	keys = { { "<leader>m", "<cmd>lua require('codewindow').toggle_minimap()<cr>" } },
	config = function()
		require("codewindow").setup({ minimap_width = 16, window_border = "" })
	end
}
