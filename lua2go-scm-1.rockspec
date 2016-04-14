 package = "Lua2Go"
 version = "scm-1"
 source = {
    url = "git://github.com/theganyo/lua2go"
 }
 description = {
    summary = "Easy access to your Go (Golang) modules from Lua and NGINX",
    detailed = [[
      This module enables easy access to Go modules from LuaJit and therefore,
      NGINX with the LuaJit module. So if you need the capabilities of Go in 
      your NGINX processing, you've come to the right place!
    ]],
    homepage = "https://github.com/theganyo/lua2go",
    license = "Apache-2.0"
 }
 dependencies = {
    "lua ~> 5.1"
 }
 build = {
    type = "builtin",
    modules = {
      lua2go = "lua/lua2go.lua"
    }
 }