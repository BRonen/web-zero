
local ffi = require('ffi')

ffi.cdef[[
    const int printf();
    const void aaa();
]]

local std = ffi.load('./libzero.so', true)

print(std, ffi.C.printf, ffi.C)
