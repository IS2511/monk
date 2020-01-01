function start ()
  local x = require("p2p")
  if not x.start() then
    io.stderr:write("Service is already running\n")
    return 1
  end
  return 0
end

function stop ()
  local x = require("p2p")
  x.stop()
end

-- function restart ()
--   local x = require("oc-p2p")
--   x.restart()
-- end
