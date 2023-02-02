require("lib.test").set_config({
	report = {
		-- full = true,
	},
})

describe("tables", function()
	test("filter", function()
		expect(tbl.filter({ 1, 2, 3, 4, 5 }, function(i)
			return i % 2 == 1
		end)).toEqual({ 1, 3, 5 })
	end)

	test("map", function()
		expect(tbl.map({ 1, 2, 3 }, function(i)
			return i * 2
		end)).toEqual({ 2, 4, 6 })
	end)

	test("values", function()
		local values = tbl.values({ name = "JR", age = 137 })

		expect(#values).toBe(2)
		expect(tbl.includes(values, "JR")).toBe(true)
		expect(tbl.includes(values, 137)).toBe(true)
	end)

	test("keys", function()
		local keys = tbl.keys({ name = "JR", age = 137 })

		expect(#keys).toBe(2)
		expect(tbl.includes(keys, "name")).toBe(true)
		expect(tbl.includes(keys, "age")).toBe(true)
	end)

	test("isEqual", function()
		expect(tbl.isEqual({ 1, 2, 3 }, { 1, 2, 3 })).toBe(true)
		expect(tbl.isEqual({ 1, true, "One" }, { 1, true, "One" })).toBe(true)

		local t = {}
		expect(tbl.isEqual({ 1, 2, t }, { 1, 2, t })).toBe(true)
		expect(tbl.isEqual({ 1, 2, {} }, { 1, 2, {} })).toBe(false)

		expect(tbl.isEqual({
			name = "JR",
			age = 137,
		}, {
			name = "JR",
			age = 137,
		})).toBe(true)
	end)

	test("isDeepEual", function()
		expect(tbl.isDeepEqual(
			{ 1, 2, {
				name = "JR",
				age = 137,
			} },
			{ 1, 2, {
				name = "JR",
				age = 137,
			} }
		)).toBe(true)

		expect(tbl.isDeepEqual({ 1, 2, {} }, { 1, 2, {} })).toBe(true)
	end)

	test("merge", function()
		expect(tbl.merge({ 1, 2, 3 }, { 1, 3, 5 })).toEqual({
			1,
			2,
			3,
			1,
			3,
			5,
		})

		local t = {}
		expect(tbl.merge({
			2,
			one = 1,
			two = "STR",
		}, {
			137,
			three = t,
			one = 7,
		})).toEqual({
			2,
			137,
			one = 7,
			two = "STR",
			three = t,
		})
	end)

	test("deepMerge", function()
		expect(tbl.deepMerge({
			one = 137,
			two = {
				three = "Meow",
			},
		}, {
			two = {
				three = "XXX",
			},
		})).toDeepEqual({
			one = 137,
			two = {
				three = "XXX",
			},
		})
	end)

	test("every", function()
		expect(tbl.every({ 1, 2, 3, 4, 5 }, function(item)
			return item < 10
		end)).toBe(true)
		expect(tbl.every({ 1, 2, 3, 4, 5 }, function(item)
			return item < 5
		end)).toBe(false)
	end)

	test("some", function()
		expect(tbl.some({ 1, 2, 3, 4, 5 }, function(item)
			return item == 3
		end)).toBe(true)

		expect(tbl.some({ 1, 2, 3, 4, 5 }, function(item)
			return item > 10
		end)).toBe(false)
	end)

	test.only("find", function()
		expect(tbl.find({ 1, 2, 3, 4, 5 }, function(item)
			return item == 3
		end)).toBe(3)

		local t = { name = "JR" }
		expect(tbl.find({ 1, 2, t }, function(item)
			return is.table(item) and item.name == "JR"
		end)).toBe(t)
	end)
end)
