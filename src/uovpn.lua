#!/usr/bin/lua

local ubus = require("ubus")
local uloop = require("uloop")
local uci = require("uci")

local mgmt = require("ubus_openvpn_module.management")
local clients = require("ubus_openvpn_module.clients")

uloop.init()
local conn = ubus.connect();

if not conn then
    error("Ubus connection failed")
end

local cursor = uci.cursor()
local slist = {}

cursor:foreach("openvpn", "openvpn", function(s)
    if s.name then
        local mgmt_host, mgmt_port
        if s.extra then
            for _, line in ipairs(s.extra) do
                local host, port = line:match("^management%s+(%S+)%s+(%d+)")
                if host and port then
                    mgmt_host, mgmt_port = host, tonumber(port)
                    break
                end
            end
        end
        table.insert(slist, {
            name = s.name,
            mgmt_host = mgmt_host or "localhost",
            mgmt_port = mgmt_port or 7505,
        })
    end
end)

local ovpn_methods = {
    openvpn = {
        servers = {
            function(req, msg)
                for _, s in ipairs(slist) do
                    conn:reply(req, {
                        name = s.name,
                        management_host = s.mgmt_host,
                        management_port = s.mgmt_port,
                    })
                end
            end, {}
        },
    },
}

for _, server in ipairs(slist) do
    ovpn_methods["openvpn." .. server.name] = {
        clients = {
            function(req, msg)
                local data = mgmt.send_cmd(server.mgmt_host, server.mgmt_port, "status 2")
                local clients_list = clients.parse_client_list(data)
                conn:reply(req, clients_list)
            end, {}
        },
        disconnect = {
            function(req, msg)
                if not msg or not msg.name then
                    conn:reply(req, {error = "Missing parameter"})
                    return
                end
                local data = mgmt.send_cmd(server.mgmt_host, server.mgmt_port, "kill " .. msg.name)
                conn:reply(req, {message = data})
            end, {name = ubus.STRING}
        },
    }
end

conn:add(ovpn_methods)

uloop.run()