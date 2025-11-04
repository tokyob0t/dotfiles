local async_exec = require('astal.process').async_exec

---@async
return function(...) return async_exec { 'swww', ... } end
