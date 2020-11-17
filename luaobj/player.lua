local obj = require "obj"
local log = require "log"
local crequest = require "crequest"

local player = obj.init( "player" )

function player.onNew( info, cagent )
    print( 'player.onNew:', info, cagent )
    -- player.xxx = info.xxx

    player.cagent = cagent


    -- player:startTick( 100, 1000 ) / player.tick100() player.tick1000() / player:stopTick( )
end

function player.onClear( )

end

local heartbeatcount
function player.tick1000( )
    heartbeatcount = ( heartbeatcount or 0 ) + 1

    player.reply( 'heartbeat', { code = heartbeatcount } )
end

function player.request( reqkey, data )
    assert( reqkey )
    assert( crequest[reqkey] )

    log.info( 'reqkey:'..reqkey )

    crequest[reqkey]( player, data )
end

function player.reply( repkey, data )
    assert( player.cagent )

    log.info( 'repkey:'..repkey )

    player.cagent.send( { k = repkey, d = data } )
end

function player.reconnect( )

end

return player