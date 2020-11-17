local request = { }

function request.createrole( player, info )
    player.reply( 'createrole_result', 0 )
end

function request.starttick( player, info )
    print( 'starttick' )
    player:startTick( 1000 )
end

function request.stoptick( player, info )
    print( 'stoptick' )
    player.stopTick( )
end

return request