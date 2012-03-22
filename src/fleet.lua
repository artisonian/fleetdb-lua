module("Fleet", package.seeall)

local cjson = require "cjson"

local function checkerror (e)
  if e then error(e) end
end

local function parsejson (j)
  local v, err = cjson.decode(j)
  checkerror(err)

  return unpack(v)
end

local protocol = {
  newline = "\r\n",
  success = 0
}

local prototype = {}

prototype.query = function (client, q)
  local req = cjson.encode(q)
  
  client.socket:send(req)
  client.socket:send(protocol.newline)

  local line, err = client.socket:receive()
  checkerror(err)

  local status, value = parsejson(line)

  if status == protocol.success then
    return value
  else
    error(value)
  end
end

prototype.close = function (client)
  if client.socket then
    client.socket:close()
  end
end

function new (options)
  options = options or {}

  local o = {
    host = "127.0.0.1",
    port = 3400,
    json = require("cjson")
  }

  for _,v in ipairs({"host", "port", "password"}) do
    o[v] = options[v] or o[v]
  end

  setmetatable(o, {__index = prototype})
  o.socket = assert(require("socket").connect(o.host, tonumber(o.port)))

  if o.password then
    o:query{"auth", o.password}
  end

  return o
end
