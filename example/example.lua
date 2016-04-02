-- ensure the lua2go lib is on the LUA_PATH so it will load
-- normally, you'd just put it on the LUA_PATH
package.path = package.path .. ';../lua/?.lua'

-- load lua2go
local lua2go = require('lua2go')

-- load my Go library
local example = lua2go.Load('./example.so')

-- copy just the extern functions from benchmark.h into ffi.cdef structure below
-- (the boilerplate cgo prologue is already defined for you in lua2go)
-- this registers your Go functions to the ffi library..
lua2go.Externs[[
  extern GoInt add(GoInt p0, GoInt p1);
  extern GoString concat(GoSlice p0, GoString p1);
]]

-- all set up, now you may call your Go functions! --

-- Let's do the easy one first...

-- note that Lua numbers in the parameters are auto-converted to GoInts (yay!)
-- but... the result will still be a GoInt...
local goAddResult = example.add(1, 1)

-- which means we need to convert it - easy with a call to lua2go.ToLua()
-- we use capitalized exported functions, so you Go folks feel right at home!
local addResult = lua2go.ToLua(goAddResult)

print('1 + 1 = ' .. addResult)


-- that was easy, but let's try a more interesting one --

-- we'll start with an array table of strings
local strings = {
  'Lua2Go',
  'is',
  'cool'
}

-- then convert the table to a slice of Go strings
local goSliceOfStrings = lua2go.ToGo(strings)

-- make a GoString for the separator
local separator = lua2go.ToGo(' ')

-- call our Go concat function
local goConcatResult = example.concat(goSliceOfStrings, separator)

-- convert to Lua
local luaConcatResult = lua2go.ToLua(goConcatResult)

print('Admit it, ' .. luaConcatResult)
