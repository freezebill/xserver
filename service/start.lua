local skynet = require "skynet"

skynet.start(function()
    skynet.error("Server start")

    local cagentmgr = skynet.uniqueservice("cagentmgr")
	skynet.call(cagentmgr, "lua", "start")

    skynet.exit()
end)