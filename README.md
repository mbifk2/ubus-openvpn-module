# OpenVPN module for ubus
## Description

Allows control of OpenVPN instances through ubus. Runs on OpenWRT.

Provided ubus methods:
```
'openvpn'
"servers":{} # lists all instances on the current device
"disconnect":{"name":"String"} # kills the provided client

'openvpn.<server_name>'
"clients":{} # lists all clients on the given server along with their addresses, RX/TX bytes and uptime.

```

## Build
Desktop Linux:

Simply copy everything from the `lib/` directory to `/usr/local/lua/<lua_version>/ubus_openvpn_module`.

OpenWRT:

Copy the `package/` directory over to your OpenWRT root and include `ubus-openvpn-module` in your config menu. Then, simply run `make package/utils/ubus-openvpn-module/{clean,compile} V=s` from your OpenWRT root.

Copy the package binary and install. Start the service by running `/etc/init.d/ubus-openvpn-module start`. At least one OpenVPN instance needs to be running for the module to start.