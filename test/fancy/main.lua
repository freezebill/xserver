-- _dofile( "json.lua" )
_dofile( "net.lua" )
_dofile( "json.lua" )
_dofile( "gs.lua" )


_app:onKeyDown(function(keycode)
    if( keycode == _System.Key1 ) then
        _dofile( "do1.lua" )
    end
    if( keycode == _System.Key2 ) then
        _dofile( "do2.lua" )
    end
    if( keycode == _System.Key3 ) then
        _dofile( "do3.lua" )
    end
    if( keycode == _System.Key4 ) then
        _dofile( "do4.lua" )
    end
    if( keycode == _System.Key5 ) then
        _dofile( "do5.lua" )
    end
end)
