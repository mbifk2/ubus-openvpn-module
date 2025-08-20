local socket = require("socket")

local M = {}

function M.send_cmd(cmd)
    local tcp = socket.tcp()
    tcp:connect("localhost", 7505)
    if not tcp then
        error("Failed to connect to server")
        return
    end

    tcp:send(cmd .. "\n")
    local data = {}
    while true do
        local line = tcp:receive()
        if not line or line:match("^END") then
            break
        end
        table.insert(data, line)
    end
    tcp:close()
    return table.concat(data, "\n")
end

return M