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
  monk.stop()
end

-- function restart ()
--   local monk = require("monk")
--   monk.restart()
-- end
