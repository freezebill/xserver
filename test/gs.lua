_G.GS = { }

GS.key            = 'gameserver'
GS.address        = '192.168.1.59:8888'
GS.connecttimeout = 5
GS.registfunc     = { }

function GS.onConnect( )
    print( 'onConnect' )
end

function GS.onFail( )
    print( 'onFail' )
end

function GS.onClose( reason )
    print( 'onClose ' .. ( reason or 'passive close' ) )
end

function GS.onReceive( data )
    local data = json.decode( data )
    assert( GS.registfunc[data.k], 'no regist:'..data.k )
    GS.registfunc[data.k]( data.d )
end

function GS.regist( k, func )
    assert( GS.registfunc[k] == nil, 'registed:'..k )
    GS.registfunc[k] = func
end

function GS.connect()
    Net.connect( GS.key, GS.address, GS.onConnect, GS.onFail, GS.onClose, GS.onReceive, GS.connecttimeout )
end

function GS.send( reqkey, data )
    assert( Net.isConnected( GS.key ), 'not connected')

    Net.send( GS.key,  json.encode( { k = reqkey, d = data } ) )
end