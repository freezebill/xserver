local skynet = require "skynet"

local cgate
local cgateconfig = { port = 8888, maxclient = 5000, nodelay = true }

local server = { }
local CMD = { }

-- pre create
local precreate = 20
local preagent = { }

local uid_serverid2agent = { }
-- after init regist
local fd2agent = { }
local uid2agent = { }
local pid2agent = { }
local name2agent = { }

local agentinfo = { }

function server.agent( )
    if #preagent > 0 then
        local agent = preagent[#preagent]
        preagent[#preagent] = nil
        return agent
    end

    return skynet.newservice("cagent")
end

function CMD.start( )
    skynet.call( cgate, "lua", "open" , cgateconfig )
end

-- from login service
function CMD.login_success( fd, info ) -- fd, info
    -- unknown
    if fd2agent[fd] then
        return -201
    end

    -- reconnected
    if uid_serverid2agent[ info.uid .. '_' .. info.serverid ] then
        skynet.send( uid_serverid2agent[ info.uid .. '_' .. info.serverid ], "lua", "reconnected", fd, info )
        return 0
    end

    -- same uid but connect to another serverid
    if uid2agent[ uid ] then
        -- maybe not accessable
        -- server.login_another( fd, info )
        return -202
    end

    -- login new
    local agent = server.agent( )
    skynet.call( agent, "lua", "login", fd, info )
    return 0
end

-- regist agent
function CMD.regist_agent( agent, fd, uid, pid, name, serverid )
    if fd then fd2agent[fd] = agent end
    if uid then uid2agent[uid] = agent end
    if pid then pid2agent[pid] = agent end
    if name then name2agent[name] = agent end

    agentinfo[agent] = agentinfo[agent] or { }
    agentinfo[agent] = { fd = fd, uid = uid, pid = pid, name = name, serverid = serverid }
end

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd,...)
        local f = CMD[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            skynet.error( 'no cmd:' .. cmd )
        end
    end)

    -- open service
    cgate = skynet.uniqueservice("cgate")
end)