local skynet = require "skynet"
local socket = require "skynet.socket"
local json = require "json"
local log = require "log"

local client_fd
local gate
-- local REQUEST = require "crequest" -- from client
local CMD = { }     -- from other
local server = { }  -- local

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.tostring,
    dispatch = function ( fd, _, msg )
        skynet.ignoreret()
        local info = json.decode( msg )
		-- if REQUEST[info.k] then
		-- 	REQUEST[info.k]( info.d )
		-- else
		-- 	log.warn( 'non-exist REQUEST:', info.k, info.d )
		-- end
	end,
}

function CMD.login( fd, info )
	client_fd = fd

	skynet.call( gate, "lua", "forward", fd )
end

function CMD.reconnect( fd, info )
	client_fd = fd

	skynet.call( gate, "lua", "forward", fd )
end

function CMD.socket_close( fd )
	-- todo wait reconnect


end

skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            skynet.error( 'no cmd:' .. cmd )
        end
    end)

	gate = skynet.queryservice('cgate')
end)