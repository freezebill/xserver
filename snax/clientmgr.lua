local skynet = require "skynet"
local snax = require "skynet.snax"

local config_gate = {
    ser_nums = 8,
    port_start = 8801,
    maxclient = 1024,
    nodelay = true,
}

local gates = {}

function response.ping(hello)

end

function response.error()

end

function init( ... )
    skynet.error("clientmgr start:", ...)

    -- start gate

end

function exit(...)
    skynet.error("clientmgr exit:", ...)
end