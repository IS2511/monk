
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


function utils.writeColor(colorFG, colorBG, ...)
  local gpu = require("component").gpu
  local oldColorFG, oldColorBG = gpu.getForeground(), gpu.getBackground()
  gpu.setForeground(colorFG)
  gpu.setBackground(colorBG)
  io.write(...)
  gpu.setForeground(oldColorFG)
  gpu.setBackground(oldColorBG)
end


function utils.log(level, ...)
  -- Levels: DEBUG, INFO, WARN, ERROR, CRITICAL
  level = level:lower()
  local colorTable = { -- FG, BG
    debug =    {0xFFFFFF, 0x000000}, -- white, black
    info =     {0x0000FF, 0x000000}, -- blue, black
    warn =     {0xFFFF00, 0x000000}, -- yellow, black
    error =    {0xFF0000, 0x000000}, -- red, black
    critical = {0xFFFFFF, 0xFF0000}  -- white, red
  }
  local fg, bg = colorTable["debug"][1], colorTable["debug"][2]
  if colorTable[level] ~= nil then
    fg, bg = colorTable[level][1], colorTable[level][2]
  end
  utils.writeColor(fg, bg, ...)
end


--function utils.logln(...)
--  utils.log(..., "\n")
--end


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

utils.uuid = {}
function utils.uuid.raw(uuidString) -- 36 chars
  -- TODO: Why "not enough memory" ???
  uuidString = string.gsub(uuidString, "-", "")
  local s = function (i)
    local a, b = string.byte(string.sub(uuidString, i, i+1))
    return string.char(16*(a-48) + (b-48))
  end
  local r = ""
  for i = 1, 31, 2 do r = r..s(i) end
  return r
end
function utils.uuid.hex(rawString) -- 16 bytes
  local raw = {string.byte(rawString, 1, 16)}
  rawString = nil
  local r = ""
  -- TODO: incorrect, pad only after division to 8 4 4 4 12?
  for i = 0, 3 do -- pad hex to 8 chars for each 32 bits
    r = r..string.format("%08x", raw[i*4+1]*16777216 + raw[i*4+2]*65536 + raw[i*4+3]*256 + raw[i*4+4])
  end
  local s = function (i, l) return string.sub(r, i, i+l) end
  return s(0, 8).."-"..s(8, 4).."-"..s(12, 4).."-"..s(16, 4).."-"..s(20, 12)
end


function utils.bitmaskParse(input)
  local bit = require("bit32")
  local result = {}

  for i = 1, #input do
    local b = string.byte(input, i)
    for j = 0, 7 do
      local bb = bit.extract(b, j, 1)
      if bb == 1 then bb = true else bb = false end
      table.insert(result, bb)
    end
  end

  return result
end


function utils.stringParse(format, input)
  local result = {}
  local start = 1

  for i = 1, #format do
    local f = format[i]
    local s = string.sub(input, start, start + f.l)
    start = start + f.l

    if f.type == "string" then
      result[f.name or i] = s
    elseif f.type == "number" then
      local r = 0
      for k, v in string.byte(s, 1, f.l) do
        r = r + (v * math.pow(256, k-1))
      end
      result[f.name or i] = r
    elseif f.type == "bitmask" then
      result[f.name or i] = self.bitmaskParse(s)
    end
  end

  return result
end

return utils
