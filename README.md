# OpenVPN module for ubus
## Description

Allows control of OpenVPN instances through ubus. Runs on OpenWRT.

Restarts on change of the OpenVPN config file. Stops if OpenVPN stops.

Provided ubus methods:
```
'openvpn.<server_name>'
"clients":{} # lists all clients on the given server along with their addresses, RX/TX bytes and uptime.
"disconnect":{"name":"String"} # kills the provided client

```

## Important
This **will not work** if OpenVPN was compiled without the `--enable-management` flag. Make sure the management interface is able to be accessed.

Your OpenVPN instances need to have a `management <host> <port>` option in an extra section of their UCI configuration files. Like so:
```
config openvpn 'inst1'
    # other options...
    list extra 'management localhost 7505'

```

If you're getting `ECONNREFUSED` with subsequent server instances, make sure OpenVPN traffic through that port is allowed in your firewall configuration.

## Build
**Desktop Linux:**

Provided ubus, UCI and OpenVPN are taken care of and working on your system, simply run `uovpn.lua` as root.

OpenWRT:

Copy the `package/` directory over to your OpenWRT root and include `ubus-openvpn-module` in your config menu. Then, simply run `make package/utils/ubus-openvpn-module/{clean,compile} V=s` from your OpenWRT root.

Copy the package binary and install. Start the service by running `/etc/init.d/ubus-openvpn-module start`. At least one OpenVPN instance needs to be running for the module to start.