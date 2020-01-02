--[[
  Peer-to-Peer network (github.com/IS2511/monk)
  Main API for monk.

  Written by IS2511
]]--

local io = require("io")
local event = require("event")
local ser = require("serialization")
local m = require("component").modem
local d = require("component").data

local PORT = {
  main = 500,
  ping = 501,
  service = 510
}


local addressBook = {}
local state = {
  serviceRunning = false,
  online = false,
  network = "",
  friends = {}
}
local config = {
  scan = {
    enable = true,
    delay = 60,
    radius = 400
  },
  network = {
    autoconnect = true,
    filter = "*"
  },
  lowEnergyPercent = 0
}



function init ()

  local config_file, err = io.open(rootDirName.."/config.lua", "r")

  local result, err = pcall(ser.unserialize(config_file))

  m.open(PORT.main)     -- Main PORT
  m.open(PORT.ping)     -- Ping PORT
  m.open(PORT.service)  -- Service PORT

end

-- function pingNeighbours ()
function scan ()
  for k, v in pairs(nodeFriends) do
    if not v.ping then
      v.online = false
    end
    v.ping = false
  end
  m.setStrength(400) -- 400 is max
  m.broadcast(PORT.ping, ser.serialize({m="?"}))
end

function packAES (data, key)
  local serializedData = ser.serialize(data)
  local hash = d.sha256(serializedData)
  local encryptedData = d.encrypt(serializedData, key, hash:sub(1, 4))
  return { data = encryptedData, hash = hash }
end

function unpackAES (payload, key)
  local serializedData = d.decrypt(payload.data, key, payload.hash:sub(1, 4))
  return { data = ser.unserialize(serializedData), hash = ( payload.hash == d.sha256(serializedData) ) }
end


function saveMessage (msg)
  local msgFile = io.open(messageDirName..msg.payload.hash..'.emsg', 'w')
  msgFile:write(ser.serialize(msg))
  messageStack[#messageStack + 1] = msg.payload.hash
end

function loadMessage ()
  if #messageStack == 0 then
    return nil
  end
  local hash = messageStack:remove(1)
  local msgFile = io.open(messageDirName..hash..'.emsg', 'rb')
  -- b:setvbuf(vbufSize)
  local msg = ser.unserialize(msgFile:read('*a'))
  msgFile:close()
  fs.remove(messageDirName..hash..'.emsg')
  return msg
end

-- function deleteMessage (hash)
--   fs.remove(messageDirName..hash..'.emsg')
--   for k, v in pairs(messageStack) do
--     if v == hash then
--       messageStack:remove(k)
--     end
--   end
-- end

function doMessage (msg)

  msg.payload = ser.unserialize(msg.payload)


  if msg.PORT == PORT.service then       -- Service PORT

  elseif msg.PORT == PORT.ping then       -- Ping PORT

  -- PING --
  if msg.header.m == "?" then        -- Ping request
    io.write("Received ping request! Answering: ")
    io.write( "n"..tostring(hop).."\n" )
    m.setStrength(msg.distance + 1)
    m.send( msg.remoteAddress, msg.PORT, "n"..tostring(hop) )

  elseif msg.payload.m == "n" then    -- Node's answer
    local hopsRecieved = tonumber(msg.payload:sub(2))
    io.write("Received answer: n"..hopsRecieved.."\n")
    nodeFriends[msg.remoteAddress] = {hops = hopsRecieved, ping = true, online = true}


  elseif msg.payload.m == "c" then    -- Client's answer
    -- dafuq, no idea...

  end

  elseif msg.PORT == PORT.main then       -- Main PORT

  end

end


function main ()
  tty.clear()
  if config.cacheMessages then
    local msg = {}
    while true do
      msg = loadMessage()
      if msg ~= nil then
        doMessage(msg)
      end
    end
  end
  -- TODO: ???
end

function modemHandle ()
  local msg = {}
  while true do
    -- local _, localNetworkCard, remoteAddress, PORT, distance, payload = event.pull(0, "modem_message")

    _, _, msg.remoteAddress, msg.PORT, msg.distance, msg.payload = event.pull("modem_message")
    -- os.sleep(0)
    if (not config.cacheMessages) or msg.PORT == PORT.ping then
      doMessage(msg) -- All ping messages are instant
    else
      saveMessage(msg)
    end
  end

end

init()

-- local modemThread = thread.create(modemHandle)

main()


-- SIGNAL: name, arg, ...EVENT
--  EVENT: modem_message(receiverAddress: string, senderAddress: string, port: number, distance: number, ...)
