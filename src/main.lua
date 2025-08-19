local ubus = require("ubus")
local uloop = require("uloop")
local json = require("json")

uloop.init()
local conn = ubus.connect();

if not conn then
    error("Ubus connection failed")
end

local ovpn_dir = " /var/run/openvpn"

local function get_servers()
    local servers = {}
    for file in io.popen('ls -1' .. ovpn_dir):lines() do
        local s = file:match("^openvpn%-(.+)%.info$")
        if s then
            table.insert(servers, s)
        end
    end
    return servers
end

local ovpn_methods = {
    openvpn = {
        fake = {
            function(req)
            conn:reply(req, {message="hello"});
            end, {id = "fail"}
        },
    },
    servers = {
        function(req, msg)
        conn:reply(req, {message="hello"});
        print("call to servers")
        end, {id = ubus.INT32, msg = ubus.STRING}
    }
}

conn:add(ovpn_methods)

for _, s in ipairs(get_servers()) do
    local server = ovpn_dir .. "/openvpn-" .. s .. ".status"
    print("Found server: " .. s)
end

uloop.run()