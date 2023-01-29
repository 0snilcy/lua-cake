package = "lua-cake"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/0snilcy/lua-cake.git"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      ["cake"] = "lib/init.lua"
   }
}
dependencies = {
   "lua >= 5.1, < 5.4",
}
