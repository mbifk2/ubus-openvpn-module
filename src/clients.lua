local json = require("json")

local C = {}

function C.parse_client_list(data)
    local clients = {}
    for line in data:gmatch("[^\n]+") do
        if line:match("^CLIENT_LIST") then
            local fields = {}
            for field in line:gmatch("[^,]+") do
                table.insert(fields, field)
            end
            local client = {
                common_name = fields[2],
                real_address = fields[3],
                virtual_address = fields[4],
                rx_bytes = tonumber(fields[5]),
                tx_bytes = tonumber(fields[6]),
                uptime = os.date("%H:%M:%S", tonumber(fields[9]))
            }
            clients[fields[2]] = client
        end
    end
    return clients
end

return C