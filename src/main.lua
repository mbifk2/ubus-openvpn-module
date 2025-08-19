local ubus = require("ubus")
local uloop = require("uloop")

uloop.init()
local ctx = ubus.connect();

if not ctx then
    error("Ubus connection failed")
end

local ovpn_dir = " /var/run/openvpn"

local function get_servers()
    local servers = {}
    for file in io.popen('ls -1' .. ovpn_dir):lines() do
        local s = file:match("^openvpn%-(.+)%.status$")
        if s then
            table.insert(servers, s)
        else
            print("Ignoring: " .. file)
        end
    end
    return servers
end

for _, s in ipairs(get_servers()) do
    local server = ovpn_dir .. "/openvpn-" .. s .. ".status"
    print("Found server: " .. s)
end

uloop.run()