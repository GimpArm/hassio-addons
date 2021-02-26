#!/bin/bash

#Get port from config
PORT=$(jq '.ports[.ports|keys[]]' /data/options.json)

# Extract options data
jq -s '.[1].SmartFriends = .[0].options.SmartFriends
    | .[1]' /data/options.json /opt/appsettings.json | sponge /opt/appsettings.json

# armhf needs this linked to run dotnet
[ ! -f "/lib/ld-linux-armhf.so.3" ] && [ -f "/lib/arm-linux-gnueabi/ld-2.28.so" ] && ln -s /lib/arm-linux-gnueabi/ld-2.28.so /lib/ld-linux-armhf.so.3

# Run dotnet service in foreground
dotnet /opt/SmartFriends.Host.dll --urls=http://localhost:$PORT