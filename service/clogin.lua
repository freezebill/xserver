local skynet = require "skynet"
local json = require "json"
local socket = require "skynet.socket"

local cagentmgr
local server = { }
local CMD = { }

local fd2info = { }         -- fd, data
local uid2fd = { }          -- uid, fd

function server.send( fd, data )
	local package = string.pack(">s2", json.encode( data ))
	socket.write(fd, package)
end

function server.checkdata( data )
    local k = data.k
    local info = data.d

    if not k or k ~= "login" then return end
    if not info.uid then return end
    if not info.serverid then return end

    return true
end

function server.login( fd, data )
    -- logining
    if fd2info[fd] then
        server.send( fd, { k = "login_result", d = -1 } )
        return
    end

    -- check data
    if not server.checkdata( data ) then
        server.send( fd, { k = "login_result", d = -2 } )
        return
    end

    local uid = data.d.uid
    -- TODO

    -- on local check success
    fd2info[fd] = data.d
    uid2fd[uid] = fd

    -- simlulate http callback
    skynet.fork(function()
        skynet.sleep(100)
        server.login_result( uid, 0 )
    end)
end

function server.login_result( uid, code )
    local fd = uid2fd[uid]
    assert( fd, uid )
    local info = fd2info[fd]

    uid2fd[uid] = nil
    fd2info[fd] = nil

    -- success
    if code == 0 then
        code = skynet.call( cagentmgr, "lua", "login_success", fd, info )
        server.send( fd, { k = "login_result", d = code } )
    else
        server.send( fd, { k = "login_result", d = code } )
    end
end

function CMD.socket_close( fd )
    if fd2info[fd] then
        local uid = fd2info[fd].uid
        uid2fd[uid] = nil
    end
    fd2info[fd] = nil
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.tostring,
    dispatch = function ( fd, _, msg )
        skynet.ignoreret()
        server.login( fd, json.decode( msg ) )
	end,
}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            skynet.error( "no cmd:" .. cmd )
        end
    end)

    cagentmgr = skynet.queryservice("cagentmgr")
end)


