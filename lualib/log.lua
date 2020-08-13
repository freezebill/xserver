local skynet = require "skynet"

local log = { }

-- for test
function log.debug( s )
    skynet.error( '[debug]:' .. s )
end

-- for logic
function log.info( s )
    skynet.error( '[info]:' .. s )
end

-- for dangerous
function log.warn( s )
    skynet.error( '[warn]:' .. s )
end

-- for error
function log.error( s )
    skynet.error( '[error]:' .. s )
end

return log