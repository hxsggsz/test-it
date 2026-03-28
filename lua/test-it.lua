local M = {}

local function open_jest_terminal()
	local buf = vim.api.nvim_create_buf(false, true)

	vim.cmd("botright split")

	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_win_set_height(win, 15)
end

M.run_jest = function()
	local buf = open_jest_terminal()

	vim.fn.jobstart({ "npx", "jest", "--colors" }, {
		term = true,
	})

	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })

	--auto scroll
	vim.cmd("normal! G")
end

M.setup = function()
	vim.keymap.set("n", "<leader>ti", M.run_jest, {})
end

return M
