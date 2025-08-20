local ubus = require("ubus")
local uloop = require("uloop")
local uci = require("uci")
local json = require("json")

local mgmt = require("management")
local clients = require("clients")

uloop.init()
local conn = ubus.connect();

if not conn then
    error("Ubus connection failed")
end

local cursor = uci.cursor()
local slist = {}
cursor:foreach("openvpn", "openvpn", function(s)
    table.insert(slist, s[".name"])
end)

local ovpn_methods = {
    openvpn = {
        servers = {
            function(req, msg)
                for _, s in ipairs(slist) do
                    conn:reply(req, {name = s})
                end
            end, {}
        },
        disconnect = {
            function(req, msg)
                if not msg or not msg.name then
                    conn:reply(req, {error = "Missing parameter"})
                    return
                end
                local data = mgmt.send_cmd("kill " .. msg.name)
                conn:reply(req, {message = data})
            end, {name = ubus.STRING}
        },
    },
}

for _, server in ipairs(slist) do
    ovpn_methods["openvpn." .. server] = {
        clients = {
            function(req, msg)
                local data = mgmt.send_cmd("status 2")
                local clients = clients.parse_client_list(data)
                conn:reply(req, clients)
            end, {}
        },
    }
end

conn:add(ovpn_methods)

uloop.run()