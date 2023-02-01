local colors = require("term.colors")

local M = {}
local SHIFT_LENGTH = 3

local states = {
	title = "Root",
	include = {},
}

local parent_state = states
local has_only = false
local active_execute_state = nil

local config = {
	report = {
		full = false,
	},
}

local function colorize(data)
	if type(data) == "string" then
		return colors.yellow(('"%s"'):format(data))
	end

	if type(data) == "number" then
		return colors.blue(data)
	end

	if type(data) == "boolean" then
		return colors.red(data)
	end

	return tostring(data)
end

local function tostr(data)
	if is.table(data) then
		return ("{ %s }"):format(table.concat(
			tbl.map(data, function(value, key)
				value = is.table(value) and colors.magenta(("{ #%s }"):format(#tbl.keys(value))) or colorize(value)
				return is.number(key) and value or ("%s = %s"):format(key, value)
			end),
			", "
		))
	end

	return colorize(data)
end

local function print_state(data, shift)
	shift = shift or 0
	local shift_text = (" "):rep(shift * SHIFT_LENGTH)
	local status = data.success and colors.green("") or colors.red("")

	if data.type and data.type == "expect" then
		local expected = data.expected
		local received = data.received

		local l = colors.magenta("(")
		local r = colors.magenta(")")
		local d = colors.magenta(".")

		print(
			table.concat({ shift_text, status .. " ", l, tostr(received), r, d, data.title, l, tostr(expected), r }, "")
		)
	else
		local results = {
			success = 0,
			fail = 0,
		}

		if data.test then
			results = tbl.reduce(data.expects, function(r, v)
				if v.success then
					r.success = r.success + 1
				else
					r.fail = r.fail + 1
				end

				return r
			end, results)
		end

		local results_str = table.concat(
			tbl.filter.truthy({
				results.success > 0 and colors.green("#" .. results.success) or "",
				results.fail > 0 and colors.red("#" .. results.fail) or "",
			}),
			" "
		)

		print(table.concat({
			shift_text,
			status,
			colors.magenta(data.title),
			results_str,
			data.test and "t" or "",
			data.only and "o" or "",
			data.skip and "s" or "",
		}, " "))

		if data.test and (config.report.full or results.fail > 0) or data.only then
			for _, value in ipairs(data.expects or {}) do
				print_state(value, shift + 1)
			end
		end

		for _, value in ipairs(data.include or {}) do
			print_state(value, shift + 1)
		end
	end
end

local function filter_only(data)
	if data.only then
		return data
	end

	if data.test then
		return data.only and data or nil
	end

	data.include = tbl.filter(data.include, filter_only)

	if #data.include == 0 then
		return nil
	end

	return data
end

local function filter_skip(data)
	if data.skip then
		return nil
	end

	if data.test then
		return not data.skip
	end

	data.include = tbl.filter(data.include, filter_skip)

	return data
end

local function filter_state()
	if has_only then
		states = filter_only(states) or {}
		has_only = false
	end

	states = filter_skip(states) or {}
end

local function execute(data)
	if data.test then
		active_execute_state = data
		data.test()
		data.success = tbl.every(data.expects, function(state)
			return state.success
		end)
		active_execute_state = nil
	else
		data.include = tbl.map(data.include, execute)
		data.success = tbl.every(data.include, function(state)
			return state.success
		end)
	end

	return data
end

local function after_call()
	filter_state()
	execute(states)

	for _, state in ipairs(states.include) do
		print_state(state)
	end

	states.include = {}
	config = nil
end

local function call(opts, title, fn)
	local is_test = opts.is_test or false

	local state = {
		title = title,
		test = is_test and fn or nil,
		skip = opts.skip,
		only = opts.only,
		include = is_test and nil or {},
		parent = parent_state,
		expects = is_test and {} or nil,
	}

	if state.only then
		has_only = true
	end

	if parent_state == nil then
		table.insert(states, state)
	else
		table.insert(parent_state.include, state)
	end

	parent_state = state

	if not is_test then
		fn()
	end

	parent_state = state.parent

	if state.parent == states then
		after_call()
	end
end

function M.expect(received)
	local function get_expect(fn)
		return function(expected)
			local success = fn(expected)

			table.insert(active_execute_state.expects, {
				type = "expect",
				title = debug.getinfo(1, "n").name,
				expected = expected,
				received = received,
				success = success,
			})
		end
	end

	local methods = {
		toBe = get_expect(function(expected)
			return received == expected
		end),

		toEqual = get_expect(function(expected)
			return tbl.isEqual(received, expected)
		end),

		toDeepEqual = get_expect(function(expected)
			return tbl.isDeepEqual(received, expected)
		end),
	}
	return methods
end

local function get_mt(is_test)
	return {
		__index = {
			only = function(title, fn)
				return call({ is_test = is_test, only = true }, title, fn)
			end,
			skip = function(title, fn)
				return call({ is_test = is_test, skip = true }, title, fn)
			end,
		},
		__call = function(_, title, fn)
			return call({ is_test = is_test }, title, fn)
		end,
	}
end

M.test = setmetatable({}, get_mt(true))
M.describe = setmetatable({}, get_mt())

function M.set_config(cfg)
	config = tbl.deepMerge(config, cfg)
end

return M
