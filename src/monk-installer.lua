--[[
  monk-installer https://github.com/IS2511/monk
  Installer for OpenComputers monk
  Pastebin: https://pastebin.com/dpTDJfcV
  Author: IS2511
]]--

local shell = require("shell")
local fs = require("filesystem")
local io = require("io")
--local print = print -- Bring print() to local so redef not global
local os = require("os")
local comp = require("computer")

if not require("component").isAvailable("internet") then error("No internet card found!") end

local function wget(url, path)
  if not fs.isDirectory(fs.path(path)) then fs.makeDirectory(fs.path(path)) end
  shell.execute("wget -qf "..url.." "..path)
end

local github
github = {
  base = "https://raw.githubusercontent.com/IS2511/monk/",
  branch = "master",
  link = function (path)
    return github.base..github.branch.."/"..path
  end
}
local deps = {
  required = {
    {"src/lib/monk.lua", "/usr/lib/monk.lua"},
    {"src/lib/monk-config.lua", "/usr/lib/monk-config.lua"},
    {"src/lib/monk-util.lua", "/usr/lib/monk-util.lua"}
  },
  recommended = {
    {"src/monk.lua", "/usr/bin/monk.lua"},
    {"src/rc.d/monk.lua", "/etc/rd.d/monk.lua"},
  },
  docs = {
    {"README.md", "/usr/man/monk.md"}, -- TODO: Maybe better main docs?
    {"doc/mIP.md", "/usr/man/mIP.md"},
    {"doc/mBCP.md", "/usr/man/mBCP.md"},
    {"doc/mTCP.md", "/usr/man/mTCP.md"}
  },
  optional = {

  }
}
for k, v in pairs(deps) do -- now this is funny
  setmetatable(v, {
    __index = function (self, index)
      local r = rawget(self, index)
      return setmetatable({github.link(r[1]), r[2]}, {
        __call = function (self2, ...)
          wget(self2[1], self2[2])
        end
      })
    end,
    __call = function (self, ...)
      for i, v2 in ipairs(self) do v2() end
    end
  })
end


function usage()
  print([[
Usage: monk-installer [arguments]
Commands:
    -h, --help             - Print this message
    -y, --yes              - Yes to everything, automatic install
                             Installs: required, recommended, docs
    -q, --quite            - Suppress all output (except sys err)
    -i, --install <groups> - Default: required, recommended, docs
                             Also available: optional
    ]])
end



local ok, parg = pcall(require, "parg")
if not ok then
  print("[parg] Library \"parg\" not found!")
  print("[parg] Installing...")
  if not fs.isDirectory("/usr/lib") then fs.makeDirectory("/usr/lib") end
  shell.execute("pastebin get nSgXWHtp /usr/lib/parg.lua")
  print("[parg] Done installing!")
end
parg = require("parg")


-- Command-line arguments
local flags = {
  quite = false,
  yesToAll = false
}

parg.register({"help", "h"}, "flag",
        function (count) if count > 0 then usage() os.exit() end end)

parg.register({"yes", "y"}, "flag",
        function (count) flags.yesToAll = (count > 0) end)

parg.register({"quite", "q"}, "flag",
        function (count) flags.quite = (count > 0) end)

parg.register({"install", "i"}, "value",
        function (value)

        end)

local args = parg( {...} )

if () then

end





-- TODO: Remove all this
--[[ error example
./parg.lua:13: Expected table on 1, got nil
stack traceback:
	[C]: in function 'error'
	./parg.lua:13: in function <./parg.lua:12>
	(...tail calls...)
	stdin:1: in main chunk
	[C]: in ?
]]--

