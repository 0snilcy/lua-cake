local M = {
	one = 123,
}

function M.split(string, separator)
	local res = {}

	for key in string.gmatch(string, "([^" .. separator .. "]+)") do
		tbl.insert(res, key)
	end

	return res
end

return M
