local M = {}

local test_buffer_id = nil

local function open_jest_terminal()
	if test_buffer_id and vim.api.nvim_buf_is_valid(test_buffer_id) then
		local test_win_id = vim.fn.bufwinid(test_buffer_id)
		vim.api.nvim_buf_delete(test_buffer_id, { force = true })

		if test_win_id ~= -1 and vim.api.nvim_win_is_valid(test_win_id) then
			vim.api.nvim_set_current_win(test_win_id)
		else
			vim.cmd("botright 15split")
		end
	else
		vim.cmd("botright 15split")
	end

	test_buffer_id = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(test_buffer_id, "Jest Logs")

	vim.api.nvim_win_set_buf(0, test_buffer_id)

	return test_buffer_id
end

M.run_current_file = function()
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file == "" then
		return
	end

	local buf = open_jest_terminal()

	vim.fn.jobstart({ "npx", "jest", "--colors", current_file }, {
		term = true,
	})

	vim.api.nvim_set_option_value("number", false, { scope = "local" })
	vim.cmd("normal! G")
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
end

M.run_jest = function()
	local buf = open_jest_terminal()

	vim.fn.jobstart({ "npx", "jest", "--colors" }, {
		term = true,
	})

	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })

	vim.cmd("normal! G")
end

M.setup = function()
	vim.keymap.set("n", "<leader>ta", M.run_jest, {})
	vim.keymap.set("n", "<leader>tf", M.run_current_file, {})
end

return M
