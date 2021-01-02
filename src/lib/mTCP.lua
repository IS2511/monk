--[[
  monk https://github.com/IS2511/monk
  mTCP - Minecraft Transmission Control Protocol
  Developed as part of the monk network
  Author: IS2511
]]--

local event = require("event")

local socket = {}

local MAX_DATA_SIZE = 4096 -- TODO: Needed?

function socket:bind(host, port, backlog)
  local id = event.listen("modem_message", function(...)
    if select(4, ...) == port then
      socket:callback() -- TODO: ??????
    end
  end)
  if id then
    self._state.id = id
    self._state.port = port
    self.buffer = "" -- TODO: How?
    --
  else
    return nil, "Port busy"
  end
end

function socket.new ()

  return {
    _state = {id = nil, port = nil, },
    status = "dead", -- "dead", "connected", "busy"
    connect = function () end, -- connect(address, port, lport): ok, err
    bind = function () end,    -- bind(host, port, backlog): ok, err
    read = function () end,    -- read(bytes): string of bil, err
    write = function () end,   -- write(data): ok, err
    close = function () end,   -- close(): ok, err?
    callback = function () end -- callback() TODO: ??????
  }
end
