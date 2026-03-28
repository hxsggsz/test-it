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

local function get_nearest_test_name(valid_func)
	local node = vim.treesitter.get_node()

	while node do
		do
			if node:type() ~= "call_expression" then
				goto continue
			end

			local func_name_node = node:child(0)
			if not func_name_node then
				goto continue
			end

			local func_name = vim.treesitter.get_node_text(func_name_node, 0)

			if func_name ~= valid_func then
				goto continue
			end

			local arg_list = node:child(1)
			local first_arg = arg_list and arg_list:child(1)

			if first_arg then
				local text = vim.treesitter.get_node_text(first_arg, 0)
				return text:gsub("['\"]", "") -- Remove aspas e retorna
			end
		end

		::continue::
		node = node:parent()
	end

	return nil
end

M.run_it_test = function()
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file == "" then
		return
	end

	local it_text = get_nearest_test_name("it")

	if not it_text then
		print("💡 Nenhum 'it' encontrado sob o cursor.")
		return
	end

	local buf = open_jest_terminal()

	vim.fn.jobstart({ "npx", "jest", "--colors", current_file, "-t", it_text }, {
		term = true,
	})

	vim.api.nvim_set_option_value("number", false, { scope = "local" })
	vim.cmd("normal! G")

	-- Não se esqueça do atalho para fechar a janela
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
end

M.run_test_test = function()
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file == "" then
		return
	end

	local test_text = get_nearest_test_name("it")

	if not test_text then
		print("💡 Nenhum 'test' encontrado sob o cursor.")
		return
	end

	local buf = open_jest_terminal()

	-- Adicionado o current_file e a flag -t
	vim.fn.jobstart({ "npx", "jest", "--colors", current_file, "-t", test_text }, {
		term = true,
	})

	vim.api.nvim_set_option_value("number", false, { scope = "local" })
	vim.cmd("normal! G")

	-- Não se esqueça do atalho para fechar a janela
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
end
M.run_describe_test = function()
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file == "" then
		return
	end

	local describe_text = get_nearest_test_name("describe")

	if not describe_text then
		print("💡 Nenhum 'describe' encontrado sob o cursor.")
		return
	end

	local buf = open_jest_terminal()

	-- Adicionado o current_file e a flag -t
	vim.fn.jobstart({ "npx", "jest", "--colors", current_file, "-t", describe_text }, {
		term = true,
	})

	vim.api.nvim_set_option_value("number", false, { scope = "local" })
	vim.cmd("normal! G")

	-- Não se esqueça do atalho para fechar a janela
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
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
	vim.keymap.set("n", "<leader>td", M.run_describe_test, {})
	vim.keymap.set("n", "<leader>ti", M.run_it_test, {})
	vim.keymap.set("n", "<leader>tt", M.run_test_test, {})
end

return M
