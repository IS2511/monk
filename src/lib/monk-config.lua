

local config = {

  default = {
    config = {

    }
  },

  config = {}

}

local mt = {}

function mt.__index(self, index)
  for k, v in pairs(self) do
    if index == k then
      return v
    end
  end
  return rawget(self, "config")[index]
end


function mt.__newindex(self, index, value)
  rawget(self, "config")[index] = value
end


function config.parsePath(path)
  assert(type(path) == "string", "Expected <string>, got <"..type(path)..">")
  local t = {}
  for v in path:gmatch("[^.]+") do
    table.insert(t, v)
  end
  return t
end

function config.get(path)
  local result = config.config
  for i, v in ipairs(config.parsePath(path)) do
    result = result[v]
  end
  return result
end

function config.set(path, value)
  local result = config.config
  local p = config.parsePath(path)
  for i = 1, #p-1 do
    result = result[v]
  end
  result[p[#p]] = value
  return result[p[#p]]
end


function config.applyDefault()

end

function config.generateDefault()

end


function config.addDefault(path, cfg)

end


return setmetatable(config, mt)