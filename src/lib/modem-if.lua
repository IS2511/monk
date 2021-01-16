
local component = require("component")

local modem = {}
local mt = {}

function modem.reload()
  local m = component.list("modem", true)
end

mt.__index = function (self, key)

end

setmetatable(modem, mt)

return modem