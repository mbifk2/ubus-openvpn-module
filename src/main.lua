local ubus = require("ubus")
local uloop = require("uloop")
local uci = require("uci")
local json = require("json")

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
        fake = {
            function(req)
                conn:reply(req, {message="hello"})
            end, {id = "fail"}
        },
        servers = {
            function(req, msg)
                conn:reply(req, {message="hello"})
                print("call to servers")
            end, {}
        },
    },
}

for _, server in ipairs(slist) do
    ovpn_methods["openvpn." .. server] = {
        clients = {
            function(req, msg)
                conn:reply(req, {message="clients not implemented"})
            end, {}
        }
    }
end

conn:add(ovpn_methods)

uloop.run()