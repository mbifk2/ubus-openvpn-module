local socket = require("socket")

local M = {}

function M.send_cmd(cmd)
    local tcp = assert(socket.tcp())
    assert(tcp:connect("localhost", 7505))

    tcp:send(cmd .. "\n")
    local data = {}
    while true do
        local line = tcp:receive()
        if not line or line:match("^END") then
            break
        end
        if line:match("^SUCCESS") or line:match("^ERROR") then
            data = {line}
            break
        end
        table.insert(data, line)
    end
    tcp:close()
    return table.concat(data, "\n")
end

return M