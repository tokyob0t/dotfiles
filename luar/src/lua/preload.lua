local ffi = require('ffi')
local RTLD = { LAZY = 1, NOW = 2, GLOBAL = 0x100 }

ffi.cdef('void* dlopen(const char* filename, int flag);')
ffi.C.dlopen('libgtk4-layer-shell.so', RTLD.LAZY)

-- package.preload['lgi'] = function() return require('LuaGObject') end
