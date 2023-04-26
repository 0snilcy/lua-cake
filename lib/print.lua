local colors = require("term.colors")

local function colorize(value, config)
	if not config.colorize then
		return value
	end

	if is.string(value) then
		if config.length then
			return colors.yellow(('#%s "%s"'):format(#value, value))
		end
		return colors.yellow(('"%s"'):format(value))
	end

	if is.number(value) then
		return colors.blue(("%s"):format(value))
	end

	if is.boolean(value) then
		return colors.red(("%s"):format(value))
	end

	if is.fn(value) then
		return colors.red("Function")
	end

	return value
end

local function table_tostring(data, config, shift)
	if not is.table(data) then
		return colorize(data, config)
	end

	shift = shift or 1

	local deep = config.deep or 10
	local max_width = 0
	local list = {}
	local keys = #tbl.keys(data)

	local begin_br = config.length and ("{ #%s "):format(keys) or "{ "
	local result = config.colorize and colors.magenta(begin_br) or begin_br

	if keys == 0 then
		return result .. (config.colorize and colors.magenta("}") or "}")
	end

	if deep == 0 then
		local end_br = config.colorize and colors.magenta("... }") or "... }"
		return result .. end_br
	end

	for key in pairs(data) do
		if #tostring(key) > max_width then
			max_width = #tostring(key)
		end
	end

	for key, value in pairs(data) do
		if is.table(value) then
			value = table_tostring(
				value,
				tbl.deepMerge(config, {
					deep = deep - 1,
				}),
				shift + 1
			)
		else
			value = colorize(value, config)
		end

		local align = (" "):rep(max_width + 2 - #tostring(key))
		local shift_str = (" "):rep(shift * config.shift_length - 1)
		local hide_key = is.number(key) and not config.number_ids
		local eq = config.colorize and colors.magenta("=") or "="

		key = config.colorize and colors.magenta(key) or key

		local item = tbl.concat(
			tbl.filter.truthy({
				config.format and shift_str or "",
				hide_key and "" or {
					key,
					config.align and align or "",
					eq,
				},
				value,
			}),
			" "
		)

		table.insert(list, item)
	end

	table.sort(list)

	local end_br = config.colorize and colors.magenta("}") or "}"

	local new_line_sym = config.format and ",\n" or ", "
	local new_line = config.colorize and colors.magenta(new_line_sym) or new_line_sym
	local result_format_start = config.format and "%s\n%s" or "%s %s"

	result = (result_format_start):format(result, table.concat(list, new_line))

	if config.format then
		return ("%s\n%s%s"):format(result, (" "):rep((shift - 1) * config.shift_length), end_br)
	else
		return ("%s %s"):format(result, end_br)
	end
end

local log_string = function(title, data, config)
	config = tbl.deepMerge({
		length = false,
		number_ids = false,
		align = false,
		colorize = true,
		format = true,
		deep = 10,
		shift_length = 3,
	}, config or {})

	return (("%s: %s"):format(title, table_tostring(data, config)))
end

local log = function(title, data, config)
	print(log_string(title, data, config))
end

-- local data = {
-- 	17,
-- 	"print",
-- 	one = "ZUZ",
-- 	num = 137,
-- 	is_valid = false,
-- 	method = function() end,
-- 	inner = {
-- 		17,
-- 		"print",
-- 		one = "ZUZ",
-- 		num = 137,
-- 		is_valid = false,
-- 		method = function() end,
-- 	},
-- }

-- log("Table", data, {
-- 	deep = 2,
-- })

return {
	log_string = log_string,
	log = log,
}
