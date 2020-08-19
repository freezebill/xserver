local skynet = require "skynet"
local socket = require "skynet.socket"
local json = require "json"
local log = require "log"
local player = require "player"

local client_fd
local gate

local CMD = { }     -- from other
local server = { }  -- local

function server.send( fd, data )
	local package = string.pack(">s2", json.encode( data ))
	socket.write(fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.tostring,
    dispatch = function ( fd, _, msg )
        skynet.ignoreret()
        local info = json.decode( msg )

		-- player.request( info )
	end,
}

-- from clogin
function CMD.login( fd, info )
	-- TODO
	player.new( info )

	client_fd = fd
	skynet.call( gate, "lua", "forward", fd )
end

function CMD.reconnect( fd, info )
	-- TODO

	client_fd = fd
	skynet.call( gate, "lua", "forward", fd )
end

-- from cgate
function CMD.socket_close( fd )
	-- TODO

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