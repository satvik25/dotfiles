-- /etc/pipewire/wireplumber/main.lua.d/50-bluez-profile.lua

local log     = require "log"
local Session = require "pipewire.session"

Session:connect("session-added", function(self, node)
  local name = node.properties["node.name"]
  if name and name:match("^bluez_card") then
    local home   = os.getenv("HOME")
    local script = home .. "/.local/bin/audio-profiles.sh"
    log.info("Running BT profile script: ", script, " for node ", name)
    os.execute(script .. " &")
  end
end)
