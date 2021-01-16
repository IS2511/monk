--[[
  monk https://github.com/IS2511/monk
  mIP - Minecraft Internet Protocol
  TODO: Only provides routing, expect out-of-order packets and different "TTL"
  Developed as part of the monk network
  Author: IS2511
]]--

local util = require("monk-util")
local config = require("monk-config")
local event = require("event")

local mIP = {
  _name = "mIP",
  _version = 1,
  _proto = 0,
  _init = false,
  defaultConfig = {
    default = {
      hopLimit = 64
    }
  },
  config = {}
}

local MAX_PACKET_SIZE = 4096+2048+1024 -- ~140 Kbps, fuck

local config_ipbook = { -- TODO: Clean this all up
  enable = true, -- If false every message will be broadcast (Just like zn!)
  volumeSpreadMethod = "even", -- even/priority (sorted from small to big)
  volumes = { -- These all actually store 1 book, just divided in volumes
    { -- "Volume 1"
      enable = true,
      priority = 1,
      location = "/var/cache/ipbook", -- folder, auto mkdir
      maxSize = "1m", -- [b]ytes, [k]ilobytes, [m]egabytes, inf - infinity
      -- divide = { -- Overrides global ipbook.divide
      --   enable = true,
      --   method = "folder (why though?)"
      -- },
      -- compress = { -- Overrides global ipbook.compress
      --   enable = true,
      --   method = "something else? nope"
      -- }
    },
    -- { -- "Volume 2", only here for example purposes
    --   enable = false,
    --   priority = 2,
    --   location = "/tmp/ipbook", -- folder, auto mkdir
    --   maxSize = "2m", -- [b]ytes, [k]ilobytes, [m]egabytes, inf - infinity
    --   divide = { -- Overrides global ipbook.divide
    --     enable = false,
    --     method = "Sample text"
    --   },
    --   compress = { -- Overrides global ipbook.compress
    --     enable = true,
    --     method = "deflate"
    --   }
    -- }
  },
  clean = { -- Offline for long -> expire -> remove
    enable = true,
    timer = "2d" -- supports [s]econds, [m]inutes, [h]ours, [d]ays (24h)
  },
  update = { -- Book too old -> check for a new one
    enable = true,
    timer = "1h" -- supports [s]econds, [m]inutes, [h]ours, [d]ays (24h)
  },
  divide = { -- [RAM] Reducing RAM consumption if volume is too big
    enable = true, -- false -> method = "onefile", onefile is fastest
    method = "filedb" -- filedb/folder, filedb recommended, folders is weird
  },
  compress = { -- [HDD] ~May~ Will slow down volume access
    enable = false, -- Not recommended (How is your HDD smaller than RAM?)
    method = "deflate" -- Only "deflate" available now (data card T1)
  }
}

local ipbook = {}


local function genID()
  local x = math.random(1, 16777216) -- (2^8)^3
  return string.char(x%256, math.floor((x/256)%256), math.floor((x/65536)%256))
end

local function headerParse(header)
  local format = {
    { l = 1,  type = "number",  name = "version" },
    { l = 3,  type = "string",  name = "flowID" },
    { l = 3,  type = "string",  name = "packetID" },
    { l = 3,  type = "string",  name = "prevID" },
    { l = 1,  type = "number",  name = "proto" },
    { l = 1,  type = "number",  name = "hopLimit" },
    { l = 1,  type = "bitmask", name = "flags" },
    { l = 36, type = "string",  name = "src" },
    { l = 36, type = "string",  name = "dst" },
    --{ l = 3,  type = "string", name = "options" },
  }
  return util.stringParse(format, header)
end

local function headerConstruct(t)

  local s = ""
  s = s + t.version or string.char(mIP._version)
  s = s + t.flowID or string.char(0, 0, 0)
  s = s + t.packetID or genID()
  s = s + t.prevID or string.char(0, 0, 0)
  s = s + t.proto or string.char(mIP._proto)
  s = s + t.hopLimit or string.char(mIP._hopLimit)


  return s
end



function mIP.init()
  if mIP._init then
    return false
  end
  config.addDefault("proto."..mIP._name, mIP.defaultConfig)
  mIP._init = true
  return true
end


return mIP


-- TODO: Parse headers with one string.gmatch()?
-- Probably lines of x = header:sub()
-- Would like to optimize sub() calling

-- TODO: Use modem address as ip? I think yes...

-- TODO: Introduce pages? To divide volumes so less RAM usage

-- TODO: Record is one server?

-- TODO: Packet structure
--[[
send(modem_address, port, header: string, data: string)

header is pure string or serialized table? I think pure string
b = byte for easy lua string.byte(data:sub(offset, offset+size))
Size is <???> bytes and is constant
Containing:
- `version`: 1b, protocol version, current is IPv1 -> 1 (?)
- `src`: Source hardware address
- `dst`: Destination hardware address
- `fragment`: Table, if needed. See [fragmentation](#fragmentation) for more info
  - `group`: Some random number for fragment identification
  - `number`: Starts with `1`

data is serialized data, typically TCP or UDP

On hold
- `protocol`: 1b, protocol, can be IP 1 (?)
]]--

-- TODO: Read ICMPv6, NDP, ARP, IPv4, IPv6?, TCP, UDP

-- TODO: Make route dicovery great again! Create mNDP?

-- TODO: Route Discovery packet or something?
--[[
- Cache local neighbours?
- Send Route Discovery packet or something (A searches D)
- Receive answer with route? A -> B -> C -> D
  | dst A | dst B | dst C | dst D |
A |   -   |   B*  |   B   |   B   |
B |   A*  |   -   |   C*  |   C   |
C |   B   |   B*  |   -   |   D*  |
D |   C   |   C   |   C*  |   -   |
* Can be cached? They are neighbours, maybe instantly
No neighbours:
  | dst A | dst B | dst C | dst D |
A |   -   |       |   B   |   B   |
B |       |   -   |       |   C   |
C |   B   |       |   -   |       |
D |   C   |   C   |       |   -   |
]]--

-- TODO: Return header hash/"hash"? To confirm identity

-- TODO: You are a client? Just broadcast ping and connect with nearest pong
-- Server pongs every request from client? Must(?) if on move (tablet or etc.)
-- And then communicate like there is no such thing is distance ;)

--modems={}
--for a,t in component.list("modem") do
--  modems[#modems+1] = component.proxy(a)
--end
--for k,v in ipairs(modems) do
--  v.open(cfg.port)
--  print("Opened port "..cfg.port.." on "..v.address)
--end
--for a,t in component.list("tunnel") do
--  modems[#modems+1] = component.proxy(a)
--end

--local function genPacketID()
--  local npID = ""
--  for i = 1, 16 do
--    npID = npID .. string.char(math.random(32,126))
--  end
--  return npID
--end
