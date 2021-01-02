
-- local _dir = (...):match("(.-)[^%.]+$")
-- local deepcopy = require(_dir .. "deepcopy")

local utils = {}

function utils.wget (url, path)
  if not fs.isDirectory(fs.path(path)) then
    local ok, err = fs.makeDirectory(fs.path(path))
    if not ok then error(err) end
  end
  shell.execute("wget "..url.." "..path)
end


function utils.writeColor(colorF, colorB, ...)
  local gpu = require("component").gpu
  local oldColorF, oldColorB = gpu.getForeground(), gpu.getBackground()
  gpu.setForeground(colorF)
  gpu.setBackground(colorB)
  io.write(...)
  gpu.setForeground(oldColorF)
  gpu.setBackground(oldColorB)
end

function utils.log(level, ...)
  -- Levels: DEBUG, INFO, WARN, ERROR, CRITICAL
  level = level:lower()
  local colorTable = { -- front, back
    debug =    {0xFFFFFF, 0x000000}, -- white, black
    info =     {0x0000FF, 0x000000}, -- blue, black
    warn =     {0xFFFF00, 0x000000}, -- yellow, black
    error =    {0xFF0000, 0x000000}, -- red, black
    critical = {0xFFFFFF, 0xFF0000}  -- white, red
  }
  if colorTable[level] == nil then
    local f, b = colorTable["debug"][1], colorTable["debug"][2]
  else
    local f, b = colorTable[level][1], colorTable[level][2]
  end
  utils.writeColor(f, b, ...)
end

function utils.logln(...)
  utils.log(..., "\n")
end

function utils.remove_dec(num)
  return string.format("%.0f", num)
end

function utils.pad(num, l, padding)
  -- res = ""
  -- if l < num then
  --   return "ERROR"
  -- end
  -- if num < 0 then
  --   l = l - 1
  -- end
  -- for i = 1, 10 do
  --   s
  -- end
  -- return res
  return string.format("%"..padding..l.."d", num)
end

return utils
