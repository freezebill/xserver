local REQUEST = { } -- from client

function REQUEST.createrole( info )
    print( 'create role', info.job, info.gender )
end

return REQUEST