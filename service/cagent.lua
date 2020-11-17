local skynet = require "skynet"
local socket = require "skynet.socket"
local json = require "json"
local log = require "log"
local player = require "player"

local client_fd
local gate

local CMD = { }     -- from other
local server = { }	-- server function

function server.send( data )
	assert( client_fd )

	local package = string.pack(">s2", json.encode( data ))
	socket.write(client_fd, package)
end

function server.dispatch( fd, _, msg )
	skynet.ignoreret()
	local data = json.decode( msg )
	player.request( data.k, data.v )
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.tostring,
    dispatch = server.dispatch,
}

-- from clogin
function CMD.login( fd, info )
	-- TODO
	client_fd = fd

	player:new( info, server )

	skynet.call( gate, "lua", "forward", fd )
end

function CMD.reconnect( fd, info )
	-- TODO
	client_fd = fd

	-- player.reconnect(  )

	skynet.call( gate, "lua", "forward", fd )
end

-- from cgate
function CMD.socket_close( fd )
	-- TODO
	player:clear( )

	client_fd = nil

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