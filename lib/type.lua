local function truthy(arg)
  -- print('truthy', arg, type(arg))
	local type = type(arg)

	if type == "string" then
		return #arg > 0
	elseif type == "boolean" then
		return arg
	elseif type == "number" then
		return arg ~= 0
	elseif type == "table" or type == "function" then
		return true
	end

	return false
end

local M = {
	table = function(arg)
		return type(arg) == "table"
	end,
	string = function(arg)
		return type(arg) == "string"
	end,
	boolean = function(arg)
		return type(arg) == "boolean"
	end,
	number = function(arg)
		return type(arg) == "number"
	end,
	fn = function(arg)
		return type(arg) == "function"
	end,
	truthy = truthy,
	falsy = function(arg)
		return not truthy(arg)
	end,
}

return M
