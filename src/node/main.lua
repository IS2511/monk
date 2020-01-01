--[[
  Peer-to-Peer network (github.com/IS2511/OC-P2P)
  Node program for OC-P2P system.

  Written by IS2511 (vk.com/IS2511)
]]--


local tty = require("tty") -- tty.clear()
local io = require("io")
local fs = require("filesystem")
local event = require("event")
local thread = require("thread")
local ser = require("serialization")
local m = require("component").modem
local d = require("component").data


local rootDirName = '/node'
local messageDirName = rootDirName..'/msg'
-- local vbufSize = 8192
local port = {
  service = 51011,
  ping = 51010,
  main = 51001
}



local nodeFriends = {}
local addressBook = {}

local messageStack = {} -- Message hash in received order (works like a stack)

local config = {}



function init ()

  if fs.exists(rootDirName) then
    if not fs.isDirectory(rootDirName) then
      fs.remove(rootDirName)
      fs.makeDirectory(rootDirName)
    end
  else
    fs.makeDirectory(rootDirName)
  end

  if fs.exists(messageDirName) then
    if not fs.isDirectory(messageDirName) then
      fs.remove(messageDirName)
      fs.makeDirectory(messageDirName)
    end
  else
    fs.makeDirectory(messageDirName)
  end

  local config_file, err = io.open(rootDirName.."/config.lua", "r")

  local result, err = pcall()

  m.open(port.service)  -- Service port
  m.open(port.ping)     -- Ping port
  m.open(port.main)     -- Main port

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
  m.broadcast(port.ping, ser.serialize({m="?"}))
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


  if msg.port == port.service then       -- Service port

  elseif msg.port == port.ping then       -- Ping port

  -- PING --
  if msg.payload.m == "?" then        -- Ping request
    io.write("Received ping request! Answering: ")
    io.write( "n"..tostring(hop).."\n" )   -- Ex.: [ {"n",4} ]
    m.setStrength(msg.distance + 1)
    m.send( msg.remoteAddress, msg.port, "n"..tostring(hop) )

  elseif msg.payload.m == "n" then    -- Node's answer
    local hopsRecieved = tonumber(msg.payload:sub(2))
    io.write("Received answer: n"..hopsRecieved.."\n")
    nodeFriends[msg.remoteAddress] = {hops = hopsRecieved, ping = true, online = true}


  elseif msg.payload.m == "c" then    -- Client's answer
    -- dafuq, no idea...

  end

  elseif msg.port == port.main then       -- Main port

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
    -- local _, localNetworkCard, remoteAddress, port, distance, payload = event.pull(0, "modem_message")

    _, _, msg.remoteAddress, msg.port, msg.distance, msg.payload = event.pull("modem_message")
    -- os.sleep(0)
    if (not config.cacheMessages) or msg.port == port.ping then
      doMessage(msg) -- All ping messages are instant
    else
      saveMessage(msg)
    end
  end

end

init()

local modemThread = thread.create(modemHandle)

main()


-- SIGNAL: name, arg, ...EVENT
--  EVENT: modem_message(receiverAddress: string, senderAddress: string, port: number, distance: number, ...)
