local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local log = require "log"

local connection = {}	-- fd -> connection : { fd , client, agent , ip, mode }
local forwarding = {}	-- agent -> connection

local clogin = { }
local cloginnum = 1
local cloginmax = 8

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local handler = {}

function handler.open(source, conf)
	for i = 1, cloginmax do
		clogin[#clogin + 1] = skynet.newservice("clogin")
	end
end

function handler.message(fd, msg, sz)
	-- recv a package, forward it
	local c = connection[fd]
	if c.agent then
		-- It's safe to redirect msg directly , gateserver framework will not free msg.
		print( 'message agent' )
		skynet.redirect(c.agent, 0, "client", fd, msg, sz)
		return
	end

	print( 'message login' )
	skynet.redirect(c.clogin, 0, "client", fd, msg, sz)
end

function handler.connect(fd, addr)
	local c = {
		fd = fd,
		ip = addr,
		clogin = clogin[cloginnum],
	}
	connection[fd] = c
	cloginnum = (cloginnum + 1) > cloginmax and 1 or (cloginnum + 1)
	print( 'connected gate and loginnum:'..cloginnum )
	gateserver.openclient(fd)
end

local function unforward(c)
	if c.agent then
		forwarding[c.agent] = nil
		c.agent = nil
	end
end

local function close_fd(fd)
	local c = connection[fd]
	if c then
		unforward(c)
		connection[fd] = nil
	end
end

function handler.disconnect(fd)
	local c = connection[fd]
	if c then
		skynet.send( c.agent or c.clogin, "lua", "socket_close", fd)
	end
	close_fd(fd)
	log.debug( 'cgate disconnect', fd )
end

function handler.error(fd, msg)
	local c = connection[fd]
	if c then
		skynet.send( c.agent or c.clogin, "lua", "socket_close", fd)
	end
	close_fd(fd)
	log.error( 'cgate error', fd, msg )
end

function handler.warning(fd, size)
	log.warn( 'cgate warning', fd, size )
end

local CMD = { }

function CMD.forward(source, fd)
	local c = assert(connection[fd])
	unforward(c)
	c.agent = source
	c.clogin = nil
	forwarding[c.agent] = c
end

function CMD.kick(source, fd)
	gateserver.closeclient(fd)
end

function handler.command(cmd, source, ...)
	local f = assert(CMD[cmd])
	return f(source, ...)
end

gateserver.start(handler)
