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
  extern char* concat(GoSlice p0, GoString p1);
  extern void increment(GoInt* p0);
  extern void reverse(GoSlice p0);
]]

---------------------------------------------------------
-- all set up, now you may call your Go functions!

---------------------------------------------------------
-- Let's do the easiest one first. We'll add two ints and return the result.

-- note that Lua numbers in the parameters are auto-converted to GoInts (yay!)
-- but... the result will still be a GoInt...
local goAddResult = example.add(1, 1)

-- which means we need to convert it - easy with a call to lua2go.ToLua()
-- we use capitalized exported functions, so you Go folks feel right at home!
local addResult = lua2go.ToLua(goAddResult)

print('1 + 1 = ' .. addResult)


---------------------------------------------------------
-- What about passing an int by reference? Also, super easy!

local value = 2

-- create a Go pointer to the value
local intPtr = lua2go.ToGoPointer(value)

-- call increment, passing the pointer
example.increment(intPtr)

-- use [0] to deference the pointer
local newValue = lua2go.ToLua(intPtr[0])

print(value .. ' + 1 = ' .. newValue)


--------------------------------------------------------------------
-- Numbers are easy, but what about passing a Go Slice by reference?
-- We'll reverse a Slice of numbers

-- Note: Go Slice support is rudimentory right now and subject to change

-- we'll reverse these values
local values = { 1, 2, 3 }

-- hold on to both results
-- we'll give Go the slice, but we need the array for iteration
local goSlice, goArray = lua2go.ToGoSlice(values)

-- pass the slice to Go to reverse
example.reverse(goSlice)

-- print the reversed array
-- note: this is a Go Array, so it's zero-indexed
local countDown = ''
for i = 0, #values - 1 do
  countDown = countDown .. ' ...' .. lua2go.ToLua(goArray[i])
end
print("The final countdown" .. countDown)


--------------------------------------------------------------------------
-- Finally, let's concat an table together and return a new string from Go

-- we'll start with a table of strings
local strings = {
  'Lua2Go',
  'is',
  'pretty',
  'cool!'
}

-- then convert the table to a slice of Go strings
local goSliceOfStrings = lua2go.ToGoSlice(strings)

-- make a GoString for the separator
local separator = lua2go.ToGo(' ')

-- call our Go concat function
local result = example.concat(goSliceOfStrings, separator)

-- Important: Go allocated the return value, so we'll need to deallocate it!
-- tell the Lua garbage collector to handle this for us
lua2go.AddToGC(result)

-- convert to Lua
local luaConcatResult = lua2go.ToLua(result)

print(luaConcatResult)
