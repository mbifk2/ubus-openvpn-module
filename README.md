# OpenVPN module for ubus
## Description

Allows control of OpenVPN instances through ubus. Runs on OpenWRT.

Provided ubus methods:
```
'openvpn'
"servers":{} # lists all instances on the current device

'openvpn.<server_name>'
"clients":{} # lists all clients on the given server along with their addresses, RX/TX bytes and uptime.
"disconnect":{"name":"String"} # kills the provided client

```

## Important
This **will not work** if OpenVPN was compiled without the `--enable-management` flag. Make sure the management interface is able to be accessed.

Your OpenVPN instances need to have a `management <host> <port>` option in their configuration files.

If you're getting `ECONNREFUSED` with the second instance, make sure OpenVPN traffic through that port is allowed in your firewall configuration.

## Build
Desktop Linux:

Simply copy everything from the `lib/` directory to `/usr/local/lua/<lua_version>/ubus_openvpn_module`.

OpenWRT:

Copy the `package/` directory over to your OpenWRT root and include `ubus-openvpn-module` in your config menu. Then, simply run `make package/utils/ubus-openvpn-module/{clean,compile} V=s` from your OpenWRT root.

Copy the package binary and install. Start the service by running `/etc/init.d/ubus-openvpn-module start`. At least one OpenVPN instance needs to be running for the module to start.