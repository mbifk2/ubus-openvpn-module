#!/usr/bin/lua

local ubus = require("ubus")
local uloop = require("uloop")
local uci = require("uci")

local socket = require("socket")

uloop.init()
local conn = ubus.connect();

if not conn then
    error("Ubus connection failed")
end

local cursor = uci.cursor()
local slist = {}

local function ovpn_running() 
    local h = io.popen("pgrep openvpn")
    local r = h:read("*a")
    h:close()

    return r ~= ""
end

local function check_ovpn() 
    if not ovpn_running() then
        os.exit(1)
    end
end

local function send_cmd(host, port, cmd)
    local tcp = socket.tcp()
    if tcp:connect(host, port) then
        tcp:send(cmd .. "\n")
    end

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

local function parse_client_list(data)
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
                uptime = os.date("!%H:%M:%S", os.difftime(os.time(), tonumber(fields[8])))
            }
            clients[fields[2]] = client
        end
    end
    return clients
end

cursor:foreach("openvpn", "openvpn", function(s)
    if s.name and s.extra then
        if s.enable == "1" then
        local mgmt_host, mgmt_port
        for _, line in ipairs(s.extra) do
            local host, port = line:match("^management%s+(%S+)%s+(%d+)")
            if host and port then
                mgmt_host, mgmt_port = host, tonumber(port)
                break
            end
        end

        table.insert(slist, {
            name = s.name,
            mgmt_host = mgmt_host or "localhost",
            mgmt_port = mgmt_port or 7505,
        })
        end
    end
end)

local ovpn_methods = {}

for _, server in ipairs(slist) do
    ovpn_methods["openvpn." .. server.name] = {
        clients = {
            function(req, msg)
                local data = send_cmd(server.mgmt_host, server.mgmt_port, "status 2")
                local clients_list = parse_client_list(data)
                conn:reply(req, clients_list)
            end, {}
        },
        disconnect = {
            function(req, msg)
                if not msg or not msg.name then
                    conn:reply(req, {error = "Missing parameter"})
                    return
                end
                local data = send_cmd(server.mgmt_host, server.mgmt_port, "kill " .. msg.name)
                conn:reply(req, {message = data})
            end, {name = ubus.STRING}
        },
    }
end

conn:add(ovpn_methods)

local intv = uloop.interval(check_ovpn, 1000)

uloop.run()