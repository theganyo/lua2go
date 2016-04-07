--[[

 A library for calling into Go from LuaJit

--]]

local lua2go = {}

local ffi = require('ffi')

ffi.cdef[[
  // standard Go definitions //

  typedef signed char GoInt8;
  typedef unsigned char GoUint8;
  typedef short GoInt16;
  typedef unsigned short GoUint16;
  typedef int GoInt32;
  typedef unsigned int GoUint32;
  typedef long long GoInt64;
  typedef unsigned long long GoUint64;
  typedef GoInt64 GoInt;
  typedef GoUint64 GoUint;
  typedef float GoFloat32;
  typedef double GoFloat64;
  typedef __complex float GoComplex64;
  typedef __complex double GoComplex128;

  // static assertion to make sure the file is being used on architecture
  // at least with matching size of GoInt.
  typedef char _check_for_64_bit_pointer_matching_GoInt[sizeof(void*)==64/8 ? 1:-1];

  // change to Go struct: add 'const' declaration to char * (required by Lua FFI)
  // typedef struct { char *p; GoInt n; } GoString;
  typedef struct { const char *p; GoInt n; } GoString;

  typedef void *GoMap;
  typedef void *GoChan;
  typedef struct { void *t; void *v; } GoInterface;
  typedef struct { void *data; GoInt len; GoInt cap; } GoSlice;

  // C stdlib definitions //

  void free(void *ptr);
]]

local makeGoString = ffi.typeof('GoString')
local makeGoSlice = ffi.typeof('GoSlice')
local makeGoStringArray = ffi.typeof('GoString[?]')
local makeGoIntArray = ffi.typeof('GoInt[?]')
local identity = function(x) return x end

-- types: "nil", "number", "string", "boolean", "table", "function", "thread", or "userdata"
local goTypes = {
  number = 'GoInt',
  string = 'GoString'
}

local goArrayConstructors = {
  number = makeGoIntArray,
  string = makeGoStringArray
}

local goConverters = {
  number = identity
}
goConverters['nil'] = identity


--
-- public interface
--

-- create cdata object
lua2go.New = ffi.new

-- add cdata to garbage collector, returns GC ref
lua2go.AddToGC = function(cdata)
  return ffi.gc(cdata, ffi.C.free)
end

-- returns the typeof the Go object
lua2go.GoType = ffi.typeof

-- loads and returns a Go library
lua2go.Load = ffi.load

-- defines loaded functions
lua2go.Externs = ffi.cdef

-- convert C String to Lua
lua2go.ToLuaString = function(str)
  if ffi.typeof(str) == makeGoString then
    return ffi.string(str.p)
  else
    return ffi.string(str) -- assume char *
  end
end

-- convert Number to Lua
lua2go.ToLuaNumber = tonumber

-- converts Lua String to a Go String
function lua2go.ToGoString(str)
  if str == nil then return '' end
  return makeGoString({ str, #str })
end
goConverters['string'] = lua2go.ToGoString

-- returns the Go type a luaVar will map to
-- currently supports Go strings and ints
function lua2go.Type(luaVar)
  local luaType = type(luaVar)
  return goTypes[luaType]
end

-- retrieve a function to get the slice type for a lua table
-- note: must be an array-style table, not a map
function lua2go.SliceType(table)
  return lua2go.Type(table[1])..'[?]'
end

-- will make a Go array that is either Ints or Strings based on the first element type
-- must be an array-style table, not a map
-- currently only supports string and ints
function lua2go.ToGoArray(table)
  local luaType = type(table[1])
  local makeGoArray = goArrayConstructors[luaType]
  local goArray = makeGoArray(#table)
  local toGoType = goConverters[luaType]
  for index, value in next, table do
    goArray[index - 1] = toGoType(value)
  end
  return goArray
end
goConverters['table'] = lua2go.ToGoArray


-- will make a Go slice that is either Ints or Strings based on the first element type
-- must be an array-style table, not a map
-- returns GoSlice, backing array
function lua2go.ToGoSlice(table)
  local goArray = lua2go.ToGoArray(table)
  return makeGoSlice({ goArray, #table, #table }), goArray
end

-- retrieve a function to convert the luaVar to a goVar based on the type of luaVar
-- currently supports Go strings and ints
function lua2go.Converter(luaVar)
  return goConverters[type(luaVar)]
end

-- converts a goVar to a luaVar
-- currently supports Go strings and ints
function lua2go.ToLua(goVar)
  if goVar == nil then return nil end
  if ffi.istype('GoString', goVar) or ffi.istype('char *', goVar) then
    return lua2go.ToLuaString(goVar)
  elseif ffi.istype('GoInt', goVar) then
    return lua2go.ToLuaNumber(goVar)
  else
    error('unknown type')
  end
end

-- converts luaVar to goVar using simple type mapping
-- currently only converts strings, numbers are left alone as they are converted automatically
function lua2go.ToGo(luaVar)
  local convert = lua2go.Converter(luaVar)
  return convert(luaVar)
end

-- returns a pointer and a value holder variable
function lua2go.ToGoPointer(luaVar)
  local luaType = type(luaVar)
  local makeGoArray = goArrayConstructors[luaType]
  local ptr = makeGoArray(1, luaVar)
  return ptr, ptr[0]
end

local module_mt = {
  __newindex = (function (table, key, val) error('Attempt to write to undeclared variable "' .. key .. '"') end)
}
setmetatable(lua2go, module_mt)
return lua2go
