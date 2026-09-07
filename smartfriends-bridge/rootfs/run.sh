#!/bin/bash

# Extract options data
jq -s '.[1].SmartFriends = .[0].SmartFriends
    | .[1].Mqtt = .[0].Mqtt
    | .[1]' /data/options.json /app/appsettings.json | sponge /app/appsettings.json

# Run dotnet service in foreground
dotnet /app/SmartFriends.Host.dll --urls=http://0.0.0.0:5001;http://[::]:5001