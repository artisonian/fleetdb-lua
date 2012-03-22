# fleetdb-lua

A Lua client for [FleetDB][fdb], based on the [Ruby](https://github.com/mmcgrana/fleet-rb) client.
It requires the `lua-cjson` and `luasocket` libraries.

## Usage

``` lua
require "fleet"

client = Fleet.new()

client:query{"ping"}    -- "pong"
client:query{"select", "accounts", { where={"=", "id", 2} }}
  -- { { id=2, owner="Alice", credits=150} }
```

The host and port default to `"127.0.0.1"` and `3400`, but can be changed:

``` lua
client = Fleet.new({ host="68.127.150.103", port=3401 })
```

[fdb]: http://fleetdb.org/
