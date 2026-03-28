local M = {}
local test_buffer_id = nil
local current_runner = "jest"

local runners = {
	jest = { cmd = "npx jest", filter_flag = "-t" },
	vitest = { cmd = "npx vitest run", filter_flag = "-t" },
	mocha = { cmd = "npx ts-mocha", filter_flag = "-g" },
}

local function detect_test_runner()
	local pkg_path = vim.fn.findfile("package.json", ".;")
	if pkg_path == "" then
		return "jest"
	end

	local file = io.open(pkg_path, "r")
	if not file then
		return "jest"
	end

	local content = file:read("*a")
	file:close()

	local ok, pkg = pcall(vim.json.decode, content)
	if not ok or not pkg then
		return "jest"
	end

	local deps = pkg.dependencies or {}
	local dev_deps = pkg.devDependencies or {}

	if deps["vitest"] or dev_deps["vitest"] then
		return "vitest"
	elseif deps["mocha"] or dev_deps["mocha"] or deps["ts-mocha"] or dev_deps["ts-mocha"] then
		return "mocha"
	end

	return "jest"
end

local function open_test_terminal()
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
	vim.api.nvim_buf_set_name(test_buffer_id, "Test Logs")
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
				return text:gsub("['\"]", "")
			end
		end
		::continue::
		node = node:parent()
	end
	return nil
end

local function run_tests(mode, target_func)
	local runner_cfg = runners[current_runner]
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file == "" then
		print("No file open to test")
		return
	end

	local cmd = vim.split(runner_cfg.cmd, " ")
	table.insert(cmd, "--colors")

	if mode == "file" then
		table.insert(cmd, current_file)
	elseif mode == "nearest" then
		local test_name = get_nearest_test_name(target_func)
		if not test_name then
			print("No " .. target_func .. " block found")
			return
		end
		table.insert(cmd, current_file)
		table.insert(cmd, runner_cfg.filter_flag)
		table.insert(cmd, test_name)
	end

	local buf = open_test_terminal()
	vim.fn.jobstart(cmd, {
		term = true,
		on_exit = function(_, code)
		print(code == 0 and "Test passed" or "Test failed")
		end,
	})

	vim.api.nvim_set_option_value("number", false, { scope = "local" })
	vim.cmd("normal! G")
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
end

M.run_jest = function()
	run_tests("all")
end
M.run_current_file = function()
	run_tests("file")
end
M.run_describe_test = function()
	run_tests("nearest", "describe")
end
M.run_it_test = function()
	run_tests("nearest", "it")
end
M.run_test_test = function()
	run_tests("nearest", "test")
end

M.setup = function(opts)
	current_runner = detect_test_runner()

	if opts and opts.runner then
		current_runner = opts.runner
	end

	vim.keymap.set("n", "<leader>ta", M.run_jest, { desc = "Run all tests" })
	vim.keymap.set("n", "<leader>tf", M.run_current_file, { desc = "Run current file" })
	vim.keymap.set("n", "<leader>td", M.run_describe_test, { desc = "Run nearest describe" })
	vim.keymap.set("n", "<leader>ti", M.run_it_test, { desc = "Run nearest it" })
	vim.keymap.set("n", "<leader>tt", M.run_test_test, { desc = "Run nearest test" })
end

return M
