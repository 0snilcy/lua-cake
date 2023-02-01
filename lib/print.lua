local colors = require("term.colors")

local SHIFT_LENGTH = 3
local ALIGN = false

local function table_tostring(tbl, deep, shift)
	shift = shift or 1
	deep = deep or 10
	local max_width = 0
	local keys = 0
	local list = {}

	for _ in pairs(tbl) do
		keys = keys + 1
	end

	local result = colors.magenta(("{ #%s "):format(keys))

	if keys == 0 then
		return result .. colors.magenta("}")
	end

	if deep == 0 then
		return result .. colors.magenta("... }")
	end

	for key in pairs(tbl) do
		if #tostring(key) > max_width then
			max_width = #tostring(key)
		end
	end

	for key, value in pairs(tbl) do
		if type(value) == "string" then
			value = colors.yellow(('"%s"'):format(value))
		end

		if type(value) == "number" then
			value = colors.blue(("%s"):format(value))
		end

		if type(value) == "boolean" then
			value = colors.red(("%s"):format(value))
		end

		if type(value) == "table" then
			value = table_tostring(value, deep - 1, shift + 1)
		end

		if type(value) == "function" then
			value = colors.red("Function")
		end

		if type(key) == "string" then
			key = ("%s"):format(key)
		end

		if ALIGN then
			key = key .. (" "):rep(max_width + 2 - #tostring(key))
		end

		key = (" "):rep(shift * SHIFT_LENGTH) .. key

		local item = ("%s %s %s"):format(colors.magenta(key), colors.magenta("="), value)
		table.insert(list, item)
	end

	table.sort(list)
	result = ("%s\n%s"):format(result, table.concat(list, colors.magenta(",\n")))
	return ("%s\n%s%s"):format(result, (" "):rep((shift - 1) * SHIFT_LENGTH), colors.magenta("}"))
end

local log = function(title, tbl, deep)
	local result = title or ""
	local tbl_string = tbl and table_tostring(tbl, deep) or nil

	local dots = colors.magenta("---")
	print(("%s %s: \n%s \n%s"):format(dots, result, tbl_string, dots))
end

return log
