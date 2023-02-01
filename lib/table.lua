local M = {}

function M.foreach(t, cb)
	for key, value in pairs(t) do
		cb(value, key)
	end
end

local function filter(t, cb)
	local result = {}

	for _, value in ipairs(t) do
		if cb(value) then
			table.insert(result, value)
		end
	end

	return result
end

M.filter = setmetatable({}, {
	__index = {
		truthy = function(t)
			return filter(t, is.truthy)
		end,
	},
	__call = function(_, t, cb)
		return filter(t, cb)
	end,
})

function M.map(t, cb)
	local result = {}

	M.foreach(t, function(value, key)
		M.insert(result, cb(value, key))
	end)

	return result
end

function M.values(t)
	local result = {}

	for _, value in pairs(t) do
		table.insert(result, value)
	end

	return result
end

function M.keys(t)
	local result = {}

	for key, _ in pairs(t) do
		table.insert(result, key)
	end

	return result
end

function M.find(t, fn)
	for _, value in pairs(t) do
		if fn(value) then
			return value
		end
	end

	return nil
end

function M.every(t, fn)
	for key, value in pairs(t) do
		if not fn(value, key) then
			return false
		end
	end

	return true
end

function M.isEqual(first, second)
	if is.table(first) and is.table(second) and #M.keys(first) == #M.keys(second) then
		return M.every(first, function(_, key)
			return first[key] == second[key]
		end)
	end

	return first == second
end

function M.isDeepEqual(first, second)
	if is.table(first) and is.table(second) and #M.keys(first) == #M.keys(second) then
		return M.every(first, function(value, key)
			return M.isDeepEqual(value, second[key])
		end)
	end

	return first == second
end

function M.includes(t, item)
	for _, value in pairs(t) do
		if item == value then
			return true
		end
	end

	return false
end

function M.reduce(t, fn, result)
	result = result or {}

	M.foreach(t, function(value, key)
		fn(result, value, key)
	end)

	return result
end

local function reduce_tbl(t, target)
	return M.reduce(t, function(result, value, key)
		if is.number(key) then
			M.insert(result, value)
		else
			result[key] = value
		end
	end, target)
end

function M.merge(first, second)
	local result = reduce_tbl(first, {})
	return reduce_tbl(second, result)
end

function M.deepMerge(first, second)
	-- log("deepMerge", {
	-- 	first = first,
	-- 	second = second,
	-- })
	return M.reduce(second, function(result, second_value, key)
		local first_value = first[key]
		result[key] = first_value

		if is.table(second_value) then
			result[key] = M.deepMerge(is.table(first_value) and first_value or {}, second_value)
		else
			result[key] = second_value
		end

		-- log("Result", result)
	end, M.merge({}, first))
end

function M.insert(t, ...)
	for _, value in ipairs({ ... }) do
		table.insert(t, value)
	end
end

M.concat = table.concat

return M
