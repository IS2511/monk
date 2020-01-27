
local timers = {}

function start ()
  local monk = require("monk")
  if not monk.start() then
    io.stderr:write("Service is already running\n")
    return 1
  end
  return 0
end

function stop ()
  local monk = require("monk")
  if not monk.stop() then
    io.stderr:write("Service is already stopped\n")
    return 1
  end
  return 0
end

function rehash ()
  local monk = require("monk")
  monk.rehash(false) -- false: Not starting
end

-- function restart ()
--   local monk = require("monk")
--   monk.restart()
-- end
