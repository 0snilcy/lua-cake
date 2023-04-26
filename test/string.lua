require("lib.test").set_config({
	report = {
		full = false,
	},
})

local str = require("lib.string")

describe("string", function()
	test("split", function()
		expect(str.split("/one/two/three", "/")).toEqual({
			"one",
			"two",
			"three",
		})
		expect(str.split("/home/rocket/git/rocket/.dotfiles/files/.config/nvim", "/")).toEqual({
			"home",
			"rocket",
			"git",
			"rocket",
			".dotfiles",
			"files",
			".config",
			"nvim",
		})
		expect(str.split("The quick brown fox", " ")).toEqual({
			"The",
			"quick",
			"brown",
			"fox",
		})
	end)
end)
