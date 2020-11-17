GS.regist( 'login_result', function( code )
    print( 'login_result', code )
end)

GS.regist( 'createrole_result', function( code )
    print( 'createrole_result', code )
end)

GS.regist( 'heartbeat', function( data )
    print( 'createrole_result', data.code )
end)

GS.connect( )
